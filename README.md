# db\_gaytrain

A small dirty tool that was initially written to see if the Pride DB ICE 3 is coming to your station, but now even has support for additional modules that you can write yourself. This is more of a personal repo.

### Known flaws:
* Modules are not written in a good style.
* File `checked` isn't cleaned properly... or maybe not even at all (I have no clue)

### How to add a station:
1. Find out the DS-100 (the internal DB code) of your station. For that, search either Wikipedia or, even better, [the official files provided by Deutsche Bahn](https://data.deutschebahn.com/dataset/data-betriebsstellen.html). It should be a combination of uppercase letters and maybe also spaces, like `LH`(Halle(S) Hbf), `KD`(Düsseldorf Hbf), `BHBF`(Berlin Hbf S-Bahn upper level) or `LL  T`(Leipzig Hbf tief - that's two spaces between the L and the T, and that's important!).
2. Open `stations.yaml` and append a line in the format of `DS-100: station name`. So if you were to add Hamburg Hbf, it'd be `AH: Hamburg Hbf`. Make sure to leave a space after the colon!
3. Save the file and start the monitor. 

Done! The monitor will automatically add some more info to the file(like the internal NUMERIC station ID) and overwrite it.
