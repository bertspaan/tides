require 'geocoder'
require 'json'

ports = []
JSON.parse(File.open('ports.json').read).each { |port| 
  address = "#{port["name"]}, #{port["country"]}" 
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

File.open("ports.json", 'w') { |file| file.write(JSON.pretty_generate(ports)) }
puts "Done..."
