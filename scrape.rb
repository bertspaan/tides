#!/usr/local/Cellar/ruby/1.9.3-p327/bin/ruby

require 'faraday'

url = "http://www.ukho.gov.uk/easytide/easytide/ShowPrediction.aspx?PortID=%s&PredictionLength=7"

(1095..9999).each { |port_id|  
  port_id = "%04d" % port_id
  puts port_id
  
  response = nil  
  attempts = 0
  begin
    response = Faraday.get url % [port_id]    
  rescue Exception
    attempts += 1
    puts "\t Retry ##{attempts}"
    sleep 5
    retry
  end  

  File.open("files/#{port_id}.html", 'w') { |file| file.write(response.body ) }
  sleep 0.2
}

