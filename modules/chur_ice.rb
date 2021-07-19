$TRAIN_PAYLOADS << lambda do |station, ice, reihung|

  names = reihung["allFahrzeuggruppe"].map{|i|i != nil ? i["name"] : ""}

  if names.any?{ |i| i != nil && i == "Chur"}
  
    debug "#{station[1]["name"]}: " + "ICE #{ice[0]} is named 'Chur' and has the Bundesbahnstreifen on the powerheads!"
  
  end

end
