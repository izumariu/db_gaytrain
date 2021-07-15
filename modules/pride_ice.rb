$TRAIN_PAYLOADS << lambda do |station, ice, reihung|

  names = reihung["allFahrzeuggruppe"].map{|i|i != nil ? i["name"] : ""}

  if names.any?{ |i| i != nil && i.match(/^Halle/) && i.match(/Saale/)}
  
    debug "#{station[1]["name"]}: " + "ICE #{ice[0]} IS GAY!"
  
  end

end
