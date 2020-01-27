require 'yaml'
def parse_point(s)
    point = {}
    point['_raw'] = s
    s = s.strip # trim whitespace
    
    parts = s.split(/(?<!\\) /) # split on unescaped spaces for the initial sections
    return false if parts.length < 2 # at bare minimum there needs to be a measurement and some fields

    mparts = parts[0].split(/(?<!\\),/) # split on unescaped commas for the measurement name and tags
    point['measurement'] = unescape_measurement mparts[0]
    
    # if any tags were attached to the measurement iterate over them now
    point['tags'] = {}
    mparts.drop(1).each do |t|
        tag = t.split(/(?<!\\)=/)
        point['tags'][unescape_tag tag[0]] = unescape_tag tag[1]
    end
    
    # now iterate over the values
    point['values'] = {}
    vparts = parts[1].split(/(?<!\\),/)
    vparts.each do |v|
        value = v.split(/(?<!\\)=/)
        point['values'][unescape_tag value[0]] = unescape_point value[1]
    end

    if parts.length == 3 # handle the timestamp
        point['time'] = parts[2]
    else
        # no time left for you, on my way to better things
        point['time'] = nil
    end
    point
end
def unescape_measurement(s)
    s.gsub(/\\ /,' ').gsub(/\\,/,',')
end
def unescape_tag(s)
    t = unescape_measurement s
    t.gsub(/\\=/,'=')
end
def unescape_point(s)
    if s[-1,1] == '"'

        # it's a quoted string and should be unescaped
        s = s[1..-2] # take the wrapping quotes off
        return s.gsub(/\\\\/,',').gsub(/\\"/,',')
    else
        # it's a number and if it's trailing an i we need to strip it because we're not handling precision here
        return s.chomp('i')
    end
end
string = 'wea\ ther,location=us-midwest temper\=ature=82i 1465839830100400200'
puts parse_point(string).to_yaml