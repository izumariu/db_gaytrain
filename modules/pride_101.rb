$TRAIN_PAYLOADS << lambda do |station, ic, reihung|

  reihung["allFahrzeuggruppe"].each do |gruppe|

    gruppe["allFahrzeug"].each do |fahrzeug| 

      if fahrzeug["kategorie"] == "LOK" 
  
        if fahrzeug["fahrzeugnummer"] == "918061010669"

          debug "#{station.last["name"]}: #{ic[0]} is hauled by a gay loco!"

        elsif fahrzeug["fahrzeugnummer"].match /^[0-9]+$/

          _pieces = fahrzeug["fahrzeugnummer"].match /^91806(\d{3})(\d{3})(\d)$/
          #debug "#{ic[0]} is hauled by loco #{_pieces[1]} #{_pieces[2]}-#{_pieces[3]}"
       
        else

          #debug "#{ic[0]} is hauled by an unidentified loco (\"#{fahrzeug["fahrzeugnummer"]}\")"

        end
      
      end

    end

  end

end
