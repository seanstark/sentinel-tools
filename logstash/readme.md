## Sending logs to Sentinel using Logstash

## Step 1 - Deploy the Data Collection Rule
Deploy the custom data collection rule in Azure

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fseanstark%2Fsentinel-tools%2Fmain%2Flogstash%2Flogstash-syslog-dcr.json)

## Step 2 - Create a logstash configuration file
Default directory is /etc/logstash/conf.d/

### Logstash Configuration Example

``` ruby
input {
  syslog {
    port => 11536
	type => syslog
  }
}
filter {
  grok {
    match => {
		"message" => "%{SYSLOGTIMESTAMP:ls_timestamp} %{SYSLOGHOST:hostname} %{DATA:proc}(?:\[%{POSINT:pid}\])?:%{SPACE}%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:severity} \[%{DATA:proctag}\]%{SPACE}%{GREEDYDATA:message}" 
	}
  }
  mutate {
	replace => {
	    "service" => "logstash"
		"ip" => "%{[host][ip]}"
		"hostname" => "%{[host][hostname]}"
		"severity" => "%{[log][syslog][severity][name]}"
		"facility" => "%{[log][syslog][facility][name]}"
		"pid" => "%{[process][pid]}"
		"process_name" => "%{[process][name]}"
	}
 	convert => { 
		"[pid]" => "integer"
	}
  }
}
output {
    microsoft-sentinel-logstash-output-plugin {
      client_app_Id => "<service principle app id>"
      client_app_secret => "<service principle secret>"
      tenant_id => "<service principle tenant id>"
      data_collection_endpoint => "<https url for the data collection endpoint>"
      dcr_immutable_id => "<Data Collection Rule immutable_id>"
      dcr_stream_name => "Custom-Microsoft-Syslog"
    }
}
```

## Step 3 - Configure rsyslog to forward logs to logstash

Update your rsyslog.conf or other rsyslog config files to sent to the syslog input port you defined above in the logstash config file. Example:

```
# Send all syslog to logstash
*.* @0.0.0.0:11536
```

## Test the configuration

Run logstash interactively to view console output

1. Stop the logstash service first
	```
	service logstash stop
	```

2. Add the below your logstash configuration output section
	``` ruby
	stdout {
            codec => rubydebug{}
        }
	```

3. Start logstash in interactive moode. (Specify the full path to the configuration file after -f)
	```
	/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/sentinel.conf
	```

4. To enable further debug output, open another ssh sessions and run the below
	``` 
	curl -XPUT 'localhost:9600/_node/logging?pretty' -H 'Content-Type: application/json' -d'
	    {
                "logger.logstash.inputs.syslog" : "DEBUG",
	        "logger.logstash.filters.grok" : "DEBUG",
	        "logger.logstash.outputs.microsoftsentineloutput" : "DEBUG"
	    }
	    '
	```


