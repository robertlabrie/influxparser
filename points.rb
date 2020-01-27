def parse_point(s)
    point = {}
    point['_raw'] = s
    s = s.strip # trim whitespace
    
    parts = s.split(/(?<!\\) /) # split on unescaped spaces for the initial sections
    return false if parts.length < 2 # at bare minimum there needs to be a measurement and some fields

    mparts = parts[0].split(/(?<!\\),/) # split on unescaped commas for the measurement name and tags
    point['measurement'] = mparts[0]
    
    # if any tags were attached to the measurement iterate over them now
    point['tags'] = {}
    mparts.drop(1).each do |t|
        tag = t.split(/(?<!\\)=/)
        point['tags'][tag[0]] = tag[1]
    end
    
    # now iterate over the values
    point['values'] = {}
    vparts = parts[1].split(/(?<!\\),/)
    vparts.each do |v|
        value = v.split(/(?<!\\)=/)
        point['values'][value[0]] = value[1]
    end
    point
end
string = 'wea\ ther,location=us-midwest temperature=82 1465839830100400200'
puts parse_point string