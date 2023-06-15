## Sending logs to Sentinel using Logstash

## Deploy the Data Collection Rule
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fseanstark%2Fsentinel-tools%2Fmain%2Flogstash%2Flogstash-syslog-dcr.json)

## Logstash Debugging

Run logstash interactively to view console output

```
#Stop logstash service first
service logstash stop

# Specify the full path to the configuration file after -f
/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/sentinel.conf
```

To enable debug output, open another ssh sessions and run the below
``` 
curl -XPUT 'localhost:9600/_node/logging?pretty' -H 'Content-Type: application/json' -d'
{
    "logger.logstash.inputs.syslog" : "DEBUG",
	"logger.logstash.filters.grok" : "DEBUG",
	"logger.logstash.outputs.microsoftsentineloutput" : "DEBUG"
}
'
```

## Logstash Configuration Example

```
input {
  syslog {
    port => 11536
	type => syslog
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

## Syslog Configuration

Update your rsyslog.conf or other rsyslog config files to sent to the syslog input port you defined above in the logstash config file. Example:

```
# Send all syslog to logstash
*.* @0.0.0.0:11536
```
