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

nearest_points = {}
JSON.parse(File.open('ports.geojson').read)["features"].each { |port|
  if port.has_key? "geometry"
    port_id = port["properties"]["port_id"]
    lon, lat = port["geometry"]["coordinates"]    
    nearest_point = DB[NEAREST_POINT, lon, lat, lon, lat].first
    if nearest_point
      gid = nearest_point[:gid]
      i = nearest_point[:i]
      distance = '%.2f' % nearest_point[:distance]
      puts "#{port_id}: #{gid}.#{i} (#{distance} km.)"
      
      nearest_points[gid] = {} unless nearest_points.has_key? gid      
      nearest_points[gid][i] = port_id      
    end

  end
}

File.open("nearest_points.json", 'w') { |file| file.write(JSON.pretty_generate(nearest_points)) }
puts "Done..."
