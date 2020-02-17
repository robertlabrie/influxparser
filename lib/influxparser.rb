# TODO: the tags hash should be absent when there are no tags
# TODO: time key shouldn't exist if there is no time
# TODO: deal with improper line protocol
class InfluxParser
    class << self
        def parse_point(s, options = {})
            default_options = {:parse_types => true, :time_format => nil}
            options = default_options.merge(options)

            point = {}
            point['_raw'] = s
            s = s.strip # trim whitespace
            
            measurement_end = s.index /(?<!\\) /


            mparts = s[0..measurement_end-1].split(/(?<!\\),/) # split on unescaped commas for the measurement name and tags
            point['series'] = unescape_measurement mparts[0]
            
            # if any tags were attached to the measurement iterate over them now
            point['tags'] = {}
            mparts.drop(1).each do |t|
                tag = t.split(/(?<!\\)=/)
                point['tags'][unescape_tag tag[0]] = unescape_tag tag[1]
            end
            
            # now iterate over the values
            last_value_raw = ''
            last_key = ''
            point['values'] = {}
            vparts = s[measurement_end+1..-1].split(/(?<!\\),/)
            # puts "vparts:#{vparts}"
            vparts.each do |v|
                value = v.split(/(?<!\\)=/)
                last_value_raw = value[1]
                last_key = unescape_tag value[0]
                # puts "last k/v #{last_key}==#{last_value_raw}"
                point['values'][last_key] = unescape_point(value[1],options)
            end
            # puts "-----\n#{point['values'].to_yaml}\n"

            # check for a timestamp in the last value
            # TODO: I hate this, but it's late and I just want to move past it for now
            # TODO: this level of nesting would fill rubocop with rage
            has_space = last_value_raw.rindex(/ /)
            if has_space
                time_stamp = last_value_raw[has_space+1..-1] # take everything from the space to the end
                if time_stamp.index(/"/)
                    point['timestamp'] = nil
                else
                    # it was a timestamp, strip it from the last value and set the timestamp
                    point['values'][last_key] = unescape_point(last_value_raw[0..has_space-1],options)
                    point['timestamp'] = time_stamp
                    if options[:time_format]
                        n_time = time_stamp.to_f / 1000000000
                        t = Time.at(n_time).utc
                        point['timestamp'] = t.strftime(options[:time_format])
                    end
                end    
            else
                point['timestamp'] = nil
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
        def unescape_point(s,options)
            # puts "unescape:#{s}"
            # s = s.gsub(/\\\\/,'\\').gsub(/\\"/,'""') # handle escaped characters if present

            # it is a string, return it
            return s[1..-2].gsub(/\\\\/,'\\').gsub(/\\"/,'""') if s[0,1] == '"'

            return s.sub(/(?<=\d)i/,'') if (!options[:parse_types]) # the customer doesn't care about types so just return it, but strip the trailing i from an integer because we care

            # handle the booleans
            return true if ['t','T','true','True','TRUE'].include?(s)
            return false if ['f','F','false','False','FALSE'].include?(s)

            # by here we have either an unquoted string or some numeric
            
            return s.to_f if s =~ /^(\d|\.)+$/ # floats are only digits and dots
            return s.chomp('i').to_i if s[0..-2] =~ /^(\d)+$/ # trailing i is an integer remove it
            return s.gsub(/\\\\/,'\\').gsub(/\\"/,'"')
        end
    end
end
