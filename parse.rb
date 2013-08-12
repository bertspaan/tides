#!/usr/local/bin/ruby

require 'nokogiri'
require 'json'

ports = []
Dir["files/*.html"].each { |file| 
  html = File.open(file).read
  ng = Nokogiri::HTML(html, nil, 'UTF-8')
  
  # Check for error page
  h1 = ng.css('.banner-blank h1')
  error = h1.text.strip == 'An error has occurred'
  
  unless error
    port_id = file.match(/(\d{4})/).captures.first

    name = ng.css('#PredictionSummary1_lblPortDetails').text
    country = ng.css('#PredictionSummary1_lblPortCountry').text
        
    puts "#{port_id}: #{name}, #{country}"
    
    times = []
    tides = []
    ng.css('.HWLWTableCell').each { |f|
      time_or_tide = f.text.strip
      if time_or_tide.length > 0
        if time_or_tide.include? ":"
          # time found!
          times << time_or_tide
        elsif time_or_tide.include? "m"
          # tide found!

          tides << time_or_tide.match(/(-?\d+.\d+)/).captures.first.to_f
        end
      end
    }
    
    ports << {
      :type => "Feature",
      :properties => {
        :port_id => port_id,
        :name => name,
        :country => country,
        :tides =>  Hash[times.zip(tides)]
      } 
    }    
    
  end  
}

geojson = {
  "type" => "FeatureCollection",
  "features" => ports
}

File.open("ports.geojson", 'w') { |file| file.write(JSON.pretty_generate(geojson)) }
puts "Done..."
