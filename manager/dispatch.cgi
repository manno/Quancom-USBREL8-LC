#!/usr/bin/ruby
require "rubygems"
require "rack"
require File.join(File::dirname(__FILE__), "MainWebApp.rb")
Rack::Handler::CGI.run(MainWebApp)
