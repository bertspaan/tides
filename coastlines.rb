#!/usr/local/bin/ruby

require 'json'
require 'sequel'

DB = Sequel.connect('postgres://localhost/tidalrange?user=postgres&password=postgres')

NEAREST_POINT = <<-SQL
  SELECT 
    gid, i, ST_Distance(Geography(geom), 
    Geography(ST_SetSRID(ST_MakePoint(?, ?), 4326))) / 1000 AS distance 
  FROM 
    coastline_points
  WHERE 
    ST_Distance(Geography(geom), Geography(ST_SetSRID(ST_MakePoint(?, ?), 4326))) / 1000 < 10
  ORDER BY 
    distance
  LIMIT 1
SQL

ports = []
JSON.parse(File.open('ports.geojson').read)["features"].each { |port|
  if port.has_key? "geometry"
    port_id = port["properties"]["port_id"]
    lon, lat = port["geometry"]["coordinates"]    
    nearest_point = DB[NEAREST_POINT, lon, lat, lon, lat].first
    if nearest_point
      puts port_id, nearest_point
    end
    
    #lon, lat, lon, lat



  end
}


# zoek dichtstbijzijnde stuk coastline. 
# Als < 50 km.
# Zoek dichstbijzijnde punt op stuk lijn
# Onthoud index
# 
# 
# 
# Breek kustlijnen op van gevonden index tot gevonden index.


# geojson = {
#   "type" => "FeatureCollection",
#   "features" => ports
# }
# 
# File.open("ports_geometry.geojson", 'w') { |file| file.write(JSON.pretty_generate(geojson)) }
# puts "Done..."




