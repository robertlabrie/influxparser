# TODO: the tags hash should be absent when there are no tags
# TODO: numbers shouldn't be strings
# TODO: numbers which aren't strings are floats
# TODO: numbers with a trailing i are integers -- ALERT this is actually broken
# TODO: optional timestamp parsing
# TODO: time key shouldn't exist if there is no time
# TODO: deal with improper line protocol
class InfluxParser
    class << self
        def parse_point(s)
            point = {}
            point['_raw'] = s
            s = s.strip # trim whitespace
            
            measurement_end = s.index /(?<!\\) /


            mparts = s[0..measurement_end-1].split(/(?<!\\),/) # split on unescaped commas for the measurement name and tags
            point['measurement'] = unescape_measurement mparts[0]
            
            # if any tags were attached to the measurement iterate over them now
            point['tags'] = {}
            mparts.drop(1).each do |t|
                tag = t.split(/(?<!\\)=/)
                point['tags'][unescape_tag tag[0]] = unescape_tag tag[1]
            end
            
            # now iterate over the values
            last_value = ''
            last_key = ''
            point['values'] = {}
            vparts = s[measurement_end+1..-1].split(/(?<!\\),/)
            vparts.each do |v|
                value = v.split(/(?<!\\)=/)
                last_value = unescape_point value[1]
                last_key = unescape_tag value[0]
                # puts "kv:#{last_key}==#{last_value}"
                point['values'][last_key] = last_value
            end
            
            # check for a timestamp in the last value
            # TODO: I hate this, but it's late and I just want to move past it for now
            # TODO: what happens if the last character of the last value is an escaped quote?
            has_space = last_value.rindex(/ /)
            if has_space
                time_stamp = last_value[has_space+1..-1] # take everything from the space to the end
                if time_stamp.index(/"/)
                    point['time'] = nil
                else
                    # it was a timestamp, strip it from the last value and set the timestamp
                    point['values'][last_key] = unescape_point last_value[0..has_space-1]
                    point['time'] = time_stamp
                end    
            else
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
                return s.gsub(/\\\\/,'\\').gsub(/\\"/,',')
            else
                # it's a number and if it's trailing an i we need to strip it because we're not handling precision here
                return s.chomp('i')
            end
        end
    end
end
