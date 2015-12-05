SnapCrawl Tests
===============

To run tests we need to start a small server to test against.

The `server` folder contains a suitable sinatra server. 

You need to run it before running the tests:

	$ cd server
	$ bundle     # run only once, to install server dependencies
	$ run start --daemon

To stop it:

	$ run stop


## Todo

- [ ] Make ths server start/stop automatically when testing
