all:
	@cat Makefile

ragel:
	ragel -s -R lib/lichtscript.rl
	# ragel 6.6 and ruby 1.9 fix
	perl -pi -e 's/data\[p]/data[p].ord/g' lib/lichtscript.rb

test: ragel
	ruby -d tests/test_qapi.rb
	ruby -d tests/test_lichtscript.rb
	ruby -d tests/test_actions.rb
	ruby -d tests/test_daemon.rb

run_simulator:
	ruby simulator/simulator.rb

run_daemon: ragel
	ruby -d bin/daemon.rb

run_web:
	#cd manager && ruby MainWebApp.rb
	cd manager && rackup -p 8080 -o 0.0.0.0 --env production

run_web_dev:
	cd manager && ./shotgun -p 4567 -o 0.0.0.0
