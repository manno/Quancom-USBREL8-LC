all:
	ragel -s -R lib/lichtscript.rl

tests:
	ruby tests/test_qapi.rb
	ruby tests/test_lichtscript.rb
