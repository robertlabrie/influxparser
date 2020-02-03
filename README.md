#influxparser
This gem parses InfluxDB [line protocol](https://docs.influxdata.com/influxdb/v1.7/write_protocols/line_protocol_tutorial/) into a usable Ruby hash map. It exists primarily to support [logstash-filter-influxdb](https://github.com/robertlabrie/logstash-filter-influxdb) but is a separate gem for anyone who needs it.

Pull reqeusts are welcome. The tests are based on the influx docs but there are [plenty more tests that need to be written](https://github.com/influxdata/influxdb/blob/1.8/models/points_test.go).

The [official influxdb ruby gem](https://github.com/influxdata/influxdb-ruby) supports encoding so I didn't bother.

## usage
```ruby
InfluxParser.parse_point('weather,location=us-midwest temperature="too warm" 1465839830100400200')
```

## options
The second parameter for parse_point is a hash array of options. The current options are
|--------------------------|------------------------|--------------------------------------------------|
|key                       |default                 |description                                       |
|--------------------------|------------------------|--------------------------------------------------|
|:parse_types              |false                   |Parse data types to ruby types (float, int, bool).|
|                          |                        |If false all values in the fields are treated as  |
|                          |                        |strings.                                          |
|--------------------------|------------------------|--------------------------------------------------|
