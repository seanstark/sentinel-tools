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
	if [process_name] == "%{[process][name]}" {
		mutate {
			remove_field => ["process_name", "pid"]
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

## Step 4 - Test the configuration

Run logstash interactively to view console output during testing to ensure logs are being sent to the log analytics workspace

1. Stop the logstash service first
	```
	service logstash stop
	```

2. Start logstash in interactive mode.

   ( Specify the full path to the configuration file after -f )
	```
	/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/sentinel.conf
	```

4. Verify in the console output logstash is listening on the defined local port and logs are getting sent to log analytics.

   ![image](https://github.com/seanstark/sentinel-tools/assets/84108246/4878d36c-094a-4405-8607-776ccf3fa4e3)

5. You can stop the interactive process by entering ctrl + C

## Step 5 - Run logstash as service

1. Start logstash as service
   
   Logstash will use any configuration files you have in the logstash config directory, /etc/logstash/conf.d/ by default.
   ```
   serivce logstash start
   ```

3. Verify the service is running
   ```
   serivce logstash status
   ```

## Troubleshooting

### Debug Logging
You can turn on debug logging with logstash via different methods. The methods below will work when running logstash in interactive mode.

1. Stop the logstash service first
	```
	service logstash stop
	```

2. Add the below to your logstash configuration output section
	``` ruby
	stdout {
            codec => rubydebug{}
        }
	```

3. Start logstash in interactive moode.
   
   ( Specify the full path to the configuration file after -f )
	```
	/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/sentinel.conf
	```

5. To enable further debug output, open another ssh sessions and run the below
	``` 
	curl -XPUT 'localhost:9600/_node/logging?pretty' -H 'Content-Type: application/json' -d'
	    {
                "logger.logstash.inputs.syslog" : "DEBUG",
	        "logger.logstash.filters.grok" : "DEBUG",
	        "logger.logstash.outputs.microsoftsentineloutput" : "DEBUG"
	    }
	    '
	```




