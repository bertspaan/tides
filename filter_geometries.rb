require 'json'

ports = []
JSON.parse(File.open('ports.geojson').read)["features"].each { |port| 
  ports << port if port.has_key? "geometry"
}

geojson = {
  "type" => "FeatureCollection",
  "features" => ports
}

File.open("ports_geometry.geojson", 'w') { |file| file.write(JSON.pretty_generate(geojson)) }
puts "Done..."
