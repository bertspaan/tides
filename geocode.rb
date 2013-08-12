#!/usr/local/bin/ruby

require 'geocoder'
require 'json'

ports = []
JSON.parse(File.open('ports.geojson').read)["features"].each { |port| 
  address = "#{port["properties"]["name"]}, #{port["properties"]["country"]}" 
  unless port.has_key? "geometry"
    g = Geocoder.search(address)
    unless g.empty?
      port["geometry"] = {
        "type" => "Point",
        "coordinates" => [g[0].longitude, g[0].latitude]
      }
      puts "#{address} > #{port["geometry"]["coordinates"].inspect}"
    end
    sleep 0.2  
  end
  ports << port
}

geojson = {
  "type" => "FeatureCollection",
  "features" => ports
}

File.open("ports.geojson", 'w') { |file| file.write(JSON.pretty_generate(geojson)) }
puts "Done..."
