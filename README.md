RMS9000
=======

A simple IRC bot written in Haskell using regular expressions to correct rampant misnomers.

Running it
----------
You can either compile with:
>    ghc -O --make -o rms9000 rms9000.hs

then run with:
>    ./rms9000

or alternatively use the Haskell interpreter to run it with:
>    runhaskell rms9000.hs

License
-------
Naturally I had to use the GPLv3 for this project.

Attributions
------------
A vast majority of this code comes from Don Stewart's excellent IRC bot tutorial on the Haskell wiki. I could not have done this without anon, to whom I owe my success with their excellent copypasta. And lastly, I'd like to thank Richard Stallman for creating the GNU/Linux operating system and inspiring this endeavor.

Disclaimer
----------
Freenode will ban your IP if you abuse this bot. Don't ask how I know. So yeah, don't do that.

Also, this bot is not RFC compliant. If you really want an RFC compliant copypasta bot, fork this and make it. I don't know enough about the IRC standard to do so.