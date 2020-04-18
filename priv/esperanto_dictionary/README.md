# The dictionary

This directory contains the sources for the dictionary table and the script that built them

The original sources of the dictionary table are from the Senreta Vortaro app on Github

https://github.com/zoenb/vortaro/tree/master/dictionary-src

To run the SQL builder:

* delete `dictionary.sql`
* start the server as normal `iex -S mix phx.server`
* navigate to this directory in the shell `cd("priv/esperanto_dictionary")
* compile `c("process_words.ex")
* run `ProcessWords.run()`
