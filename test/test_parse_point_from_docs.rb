$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'test/unit'
require 'influxparser'
class TestParsePointFromDocs < Test::Unit::TestCase  # def setup
  # end


  # def teardown
  # end
  
  def test_two_tags
    point = InfluxParser.parse_point('weather,location=us-midwest,season=summer temperature=82 1465839830100400200')
    assert_not_equal(false,point)   # a straight up parse error will false
    
    # measurement
    assert_equal('weather',point['measurement'])

    # tags
    assert_equal(2,point['tags'].length)

    # check location
    assert_equal(true,point['tags'].key?('location'))
    assert_equal('us-midwest',point['tags']['location'])

    # check season
    assert_equal(true,point['tags'].key?('season'))
    assert_equal('summer',point['tags']['season'])

    # value
    assert_equal(true,point['values'].key?('temperature'))
    assert_equal(82,point['values']['temperature'])
    
    # time
    assert_equal('1465839830100400200',point['time'])

    end

  def test_no_tags
    point = InfluxParser.parse_point('weather temperature=82 1465839830100400200')
    assert_not_equal(false,point)   # a straight up parse error will false

    # measurement
    assert_equal('weather',point['measurement'])

    # no tags
    assert_equal(true,point.key?('tags'))
    assert_equal(0,point['tags'].length)

    # value
    assert_equal(true,point['values'].key?('temperature'))
    assert_equal(82,point['values']['temperature'])
    
    # time
    assert_equal('1465839830100400200',point['time'])
    
  end

  def test_two_values
    point = InfluxParser.parse_point('weather,location=us-midwest temperature=82,humidity=71 1465839830100400200')
    assert_not_equal(false,point)   # a straight up parse error will false

    # measurement
    assert_equal('weather',point['measurement'])

    # check location
    assert_equal(true,point['tags'].key?('location'))
    assert_equal('us-midwest',point['tags']['location'])

    # values
    assert_equal(2,point['values'].length)

    assert_equal(true,point['values'].key?('temperature'))
    assert_equal(82,point['values']['temperature'])

    assert_equal(true,point['values'].key?('humidity'))
    assert_equal(71,point['values']['humidity'])

    # time
    assert_equal('1465839830100400200',point['time'])

  end
  def test_timestamp
    point = InfluxParser.parse_point('weather,location=us-midwest temperature=82')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_nil(point['time'])
 end

  def test_float
    point = InfluxParser.parse_point('weather,location=us-midwest temperature=82 1465839830100400200')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal(82.0,point['values']['temperature'])
  end
  def test_integer
    point = InfluxParser.parse_point('weather,location=us-midwest temperature=82i 1465839830100400200')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal(82,point['values']['temperature'])
  end

  def test_string
    point = InfluxParser.parse_point('weather,location=us-midwest temperature="too warm" 1465839830100400200')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal('too warm',point['values']['temperature'])
  end

  def test_invalid_time
    # TODO: this should be throwing a parse error
    point = InfluxParser.parse_point('weather,location=us-midwest temperature=82 "1465839830100400200"')
    assert_not_equal(false,point)   # a straight up parse error will false

  end

  def test_invalid_string
    # TODO: this should be throwing a parse error
    point = InfluxParser.parse_point("weather,location=us-midwest temperature='too warm' 1465839830100400200")
    assert_not_equal(false,point)   # a straight up parse error will false
  end

  def test_boolean
    point = InfluxParser.parse_point("weather,location=us-midwest temperature=t 1465839830100400200")
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal(true,point['values']['temperature'])

    point = InfluxParser.parse_point("weather,location=us-midwest temperature=T 1465839830100400200")
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal(true,point['values']['temperature'])

    point = InfluxParser.parse_point("weather,location=us-midwest temperature=true 1465839830100400200")
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal(true,point['values']['temperature'])

    point = InfluxParser.parse_point("weather,location=us-midwest temperature=True 1465839830100400200")
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal(true,point['values']['temperature'])

    point = InfluxParser.parse_point("weather,location=us-midwest temperature=TRUE 1465839830100400200")
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal(true,point['values']['temperature'])

    point = InfluxParser.parse_point("weather,location=us-midwest temperature=f 1465839830100400200")
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal(false,point['values']['temperature'])

    point = InfluxParser.parse_point("weather,location=us-midwest temperature=F 1465839830100400200")
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal(false,point['values']['temperature'])

    point = InfluxParser.parse_point("weather,location=us-midwest temperature=false 1465839830100400200")
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal(false,point['values']['temperature'])

    point = InfluxParser.parse_point("weather,location=us-midwest temperature=False 1465839830100400200")
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal(false,point['values']['temperature'])

    point = InfluxParser.parse_point("weather,location=us-midwest temperature=FALSE 1465839830100400200")
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal(false,point['values']['temperature'])

  end
  def test_ridiculous_quotes
    # from the influx docs: Do not double or single quote measurement names, tag keys, tag values, and field keys. It is valid line protocol but InfluxDB assumes that the quotes are part of the name.
    point = InfluxParser.parse_point('"weather","location"="us-midwest" "temperature"=82 1465839830100400200')

    assert_not_equal(false,point)   # a straight up parse error will false
    # measurement
    assert_equal('"weather"',point['measurement'])

    # check tag
    assert_equal(true,point['tags'].key?('"location"'))
    assert_equal('"us-midwest"',point['tags']['"location"'])

    # check values

    assert_equal(true,point['values'].key?('"temperature"'))
    assert_equal(82,point['values']['"temperature"'])

    # time
    assert_equal('1465839830100400200',point['time'])



    # Do the same thing for ridiculous single quotes
    point = InfluxParser.parse_point("'weather','location'='us-midwest' 'temperature'=82 1465839830100400200")

    assert_not_equal(false,point)   # a straight up parse error will false
    # measurement
    assert_equal("'weather'",point['measurement'])

    # check tag
    assert_equal(true,point['tags'].key?("'location'"))
    assert_equal("'us-midwest'",point['tags']["'location'"])

    # check values

    assert_equal(true,point['values'].key?("'temperature'"))
    assert_equal(82,point['values']["'temperature'"])

    # time
    assert_equal('1465839830100400200',point['time'])

  end

  def test_escaping
    point = InfluxParser.parse_point('weather,location=us\,midwest temperature=82 1465839830100400200')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal('us,midwest',point['tags']['location'])

    point = InfluxParser.parse_point('weather,location=us-midwest temp\=rature=82 1465839830100400200')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal(82,point['values']['temp=rature'])

    point = InfluxParser.parse_point('weather,location\ place=us-midwest temperature=82 1465839830100400200')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal(true,point['tags'].key?('location place'))

    point = InfluxParser.parse_point('wea\,ther,location=us-midwest temperature=82 1465839830100400200')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal('wea,ther',point['measurement'])

    point = InfluxParser.parse_point('wea\ ther,location=us-midwest temperature=82 1465839830100400200')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal('wea ther',point['measurement'])

    point = InfluxParser.parse_point('weather temperature=toohot\"')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal('toohot"',point['values']['temperature'])

    
    # so many slashes -- note they're extra terrible because I need to escape ruby slashes in the test strings

    # forward slash
    point = InfluxParser.parse_point('weather,location=us-midwest temperature_str="too hot/cold" 1465839830100400201')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal('too hot/cold',point['values']['temperature_str'])

    # one slash
    point = InfluxParser.parse_point('weather,location=us-midwest temperature_str="too hot\cold" 1465839830100400201')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal('too hot\cold',point['values']['temperature_str'])

    # two slashes
    point = InfluxParser.parse_point('weather,location=us-midwest temperature_str="too hot\\\cold" 1465839830100400201')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal('too hot\cold',point['values']['temperature_str'])

    # three slashes
    point = InfluxParser.parse_point('weather,location=us-midwest temperature_str="too hot\\\\\cold" 1465839830100400201')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal("too hot\\\\cold",point['values']['temperature_str'])

    # four slashes
    point = InfluxParser.parse_point('weather,location=us-midwest temperature_str="too hot\\\\\\\cold" 1465839830100400201')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal("too hot\\\\cold",point['values']['temperature_str'])

    # five slashes
    point = InfluxParser.parse_point('weather,location=us-midwest temperature_str="too hot\\\\\\\\\cold" 1465839830100400201')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal("too hot\\\\\\cold",point['values']['temperature_str'])

  end
  def test_types
    point = InfluxParser.parse_point('weather float=82,integer=82i,impliedstring=helloworld,explicitstring="hello world" 1465839830100400200')
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal(82.0,point['values']['float'])
    assert_equal(82,point['values']['integer'])
    assert_equal('helloworld',point['values']['impliedstring'])
    assert_equal('hello world',point['values']['explicitstring'])

    # do it again but this time without type parsing
    point = InfluxParser.parse_point('weather float=82,integer=82i,impliedstring=helloworld,explicitstring="hello world" 1465839830100400200',{:parse_types => false})
    assert_not_equal(false,point)   # a straight up parse error will false
    assert_equal('82',point['values']['float'])
    assert_equal('82',point['values']['integer'])
    assert_equal('helloworld',point['values']['impliedstring'])
    assert_equal('hello world',point['values']['explicitstring'])

  end
end
