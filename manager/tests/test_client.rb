#!/usr/bin/env ruby
require_relative "../lib/daemon_client.rb"
require 'pp'
@daemon_client = Webapp::DaemonClient.new
pp @daemon_client.getRelayState # [0,0,0,1...]

