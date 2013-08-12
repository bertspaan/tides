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

JSON.parse(File.open('nearest_points.json').read).each { |gid, nearest_points|  
  nearest_points = nearest_points.map {|i, port_id| [i.to_i - 1, port_id] }.sort
  puts nearest_points.inspect 

  nearest_points.each_with_index { |(i, port_id), index|

    next_index = index + 1
    next_index = 0 if next_index >= nearest_points.length
    next_i = nearest_points[next_index][0]
    puts "index: #{index}, next_index: #{next_index}"
    puts "i: #{i}, next_i: #{next_i}"
    
  }
  #points = DB[POINTS, gid].all
  #puts points.inspect
  
  #puts nearest_points.inspect #Hash[nearest_points.sort]
}

