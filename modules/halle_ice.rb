$TRAIN_PAYLOADS << lambda do |station, ice, reihung|

  names = reihung["allFahrzeuggruppe"].map{|i|i != nil ? i["name"] : ""}

  if names.any?{ |i| i != nil && i.match(/^Halle/) && i.match(/Saale/)}
  
    debug "#{station[1]["name"]}: " + halleify("ICE #{ice[0]} is the ICE with the name Halle (Saale)!")
  
  end

end
