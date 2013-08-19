#!/usr/local/bin/ruby

require 'json'
require 'sequel'

DB = Sequel.connect('postgres://localhost/tidalrange?user=postgres&password=postgres')

POINTS = <<-SQL
  SELECT 
    ST_X(geom) AS lon, ST_Y(geom) AS lat 
  FROM 
    coastline_points 
  WHERE
    gid = ?
SQL

linestrings = []
JSON.parse(File.open('nearest_points.json').read).each { |gid, nearest_points|  
  nearest_points = nearest_points.map {|i, port_id| [i.to_i - 1, port_id] }.sort
  
  # Read polygon from database
  points = DB[POINTS, gid].all
  
  nearest_points.each_with_index { |(i, port_id), index|
    next_index = index + 1
    next_index = 0 if next_index >= nearest_points.length
    
    next_i = nearest_points[next_index][0]
    next_port_id = nearest_points[next_index][1]
    
    if next_i > i
      a = (i..next_i).to_a
    else
      a = (i..points.length - 1).to_a + (0..nearest_points[0][0]).to_a
    end
    
    coordinates = a.map { |i| [points[i][:lon], points[i][:lat]]}
    
    linestrings << {
      :type => "Feature",
      :properties => {
        :ports => [port_id, next_port_id]
      },
      :geometry => {
        :type => "LineString",
        :coordinates => coordinates
      }
    }
  }
}

geojson = {
  "type" => "FeatureCollection",
  "features" => linestrings
}

File.open("coastlines.geojson", 'w') { |file| file.write(JSON.pretty_generate(geojson)) }
puts "Done..."

