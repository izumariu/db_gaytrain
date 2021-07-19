require "faraday"
require "yaml"
require "json"
require "time"

def refactor_stations

  $stations = $stations.to_a.map do |pair|

    k, v = pair

    k.is_a?(String) || abort("Fatal error: Key #{k.inspect} is not a string")
    
    if v.is_a? Hash

      pair

    elsif v.is_a? String

      ds100_resp = Faraday.get "https://marudor.de/api/stopPlace/v1/search/"+k
      ds100_resp = JSON.parse ds100_resp.body
      ds100_resp.length==0 && abort("Fatal: Station #{k.inspect} doesn't exist")

      [k, {"name" => v, "last" => 0, "id" => ds100_resp[0]["evaNumber"]}]

    else

      abort "Fatal error: Value of key #{k.inspect} is neither an Array nor a String"

    end

  end.to_h

end

def debug(s)

  puts "[#{Time.now}] "+s

end

def rainbowify(s)

  palette_b = [101, 103, 102, 106, 104, 105]
  pi = 0
  pi_s = 0 

  outs = "\e[30m"

  s.split("").each do |chr|

    outs += "\e[#{palette_b[pi.to_i]};#{palette_b[pi.to_i]}m"+chr
    pi_s += 0.5
    pi = pi_s.to_i%palette_b.length

  end

  outs + "\e[m"

end

def halleify(s)

=begin

  palette_b = [41, 47]
  pi = 0
  pi_s = 0 

  outs = "\e[30m"

  s.split("").each do |chr|

    outs += "\e[#{palette_b[pi.to_i]};#{palette_b[pi.to_i]}m"+chr
    pi_s += 0.25
    pi = pi_s.to_i%palette_b.length

  end

  outs + "\e[m"
=end

  s

end

def proper_time_format(t)

  ctime = Time.new

  (Time.parse(t)+ctime.gmtoff).strftime "%H:%M "+ctime.zone

end

# startup
$stations = YAML.load open "stations.yaml", &:read
refactor_stations
open("stations.yaml", "w") { |f| f << YAML.dump($stations) }

$TRAIN_PAYLOADS = []
Dir.glob("modules/*.rb").each do |i| 
  
  debug "Loading module #{i}..."
  load i

end

# main program loop
loop do
  
  time = Time.new
  time -= time.gmtoff
  checked = File.exist?("checked") ? open("checked", &:read).split(?\n).map(&:split).uniq : []

  $stations.each do |station|

    ds100, details = station

    debug "Checking #{details["name"]}..."

    timestamp = Time.now.to_i

    if details["last"] <= ( timestamp - 240*60 )

      deps = Faraday.get "https://marudor.de/api/iris/v2/abfahrten/"+details["id"]+"?lookahead=480&lookbehind=0"

      if deps.status != 200
      
        puts "Request for #{details["name"]} returned HTTP #{deps.status}."
        next

      end

      deps = JSON.parse(deps.body)["departures"]
      deps_ice = deps.select{ |dep| dep["train"]["type"].match /^ICE?$/ }

      ice_numbers = deps_ice.map do |ice| 
        [ice["train"]["number"].to_s, 
         ice["initialDeparture"], 
         (ice["arrival"]||ice["departure"])["scheduledTime"], 
         (ice["departure"]||ice["arrival"])["scheduledTime"], 
         ice["cancelled"],
         ice["messages"]["delay"].map{ |i| i["text"] }
        ]
      end

      ice_numbers.each do |ice|

        ice_timestamp = Time.now.to_i

        checked_set = checked.select { |i| i.last == ice[0].to_s }
        if checked_set.length == 1

          if checked_set.first.first.to_i > (ice_timestamp - 60*60*24)
            #debug "Skipping #{ice[0]}"
            next
          else
            checked.delete(checked_set.first)
          end

        end

        reihung = Faraday.get "https://marudor.de/api/reihung/v2/wagen/#{ice[0]}/#{ice[2]}"
        if reihung.status == 200
          
          reihung = JSON.parse(reihung.body)#["allFahrzeuggruppe"].map{|i|i != nil ? i["name"] : ""}
          
          $TRAIN_PAYLOADS.each do |i|
            
            i.call station, ice, reihung

          end
        
        else

          debug "Reihung for #{ice[0]} not available" + (ice[4] ? " (cancelled: #{ice[5].join(", ")})" : "")

        end

        checked << [ice_timestamp, ice[0]].map(&:to_s)
      
      end

      $stations[ds100]["last"] = timestamp

    else

      debug "#{details["name"]} doesn't need to be checked"

    end

  end

  open("checked", ?w) { |f| f << checked.map{ |i| i.join(" ") }.join(?\n) }
  #open("stations.yaml", ?w) { |f| f << YAML.dump($stations) }
  exit#debug "Sleeping..."
  sleep 120

end



