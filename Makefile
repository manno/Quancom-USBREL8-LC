all:
	@cat Makefile

ragel:
	ragel -s -R lib/lichtscript.rl

test: ragel
	ruby -d tests/test_qapi.rb
	ruby -d tests/test_lichtscript.rb
	ruby -d tests/test_actions.rb
	ruby -d tests/test_daemon.rb

run_simulator:
	ruby simulator/simulator.rb

run_daemon: ragel
	ruby -d bin/daemon.rb
