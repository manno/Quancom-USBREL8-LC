#!/usr/bin/env ruby
require 'rubygems'
require 'data_mapper'
require "../lib/model.rb"
require 'pp'
include Webapp::Model

# executed when?
#File.unlink "#{Dir.pwd}/database.db"
DataMapper::Logger.new($stdout, :debug)
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/../database.db")
Webapp::Model::migrate

# create test data
Rule.create( :type => 'clear' )
Rule.create( :type => 'tod', :created_at => Time.now, :execute_at => '18:00', :chance => '100' )
Rule.create( :type => 'tod', :created_at => Time.now, :execute_at => '19:00', :chance => '99' )
Rule.create( :type => 'tod', :created_at => Time.now, :execute_at => '20:00', :chance => '98' )
Rule.create( :type => 'pit', :created_at => Time.now, :execute_at => '2010.12.31 18:00', :chance => '100' )
Rule.create( :type => 'pit', :created_at => Time.now, :execute_at => '2010.12.31 18:00', :chance => '99' )
Rule.create( :type => 'pit', :created_at => Time.now, :execute_at => '2010.12.31 18:00', :chance => '98' )
Rule.create( :type => 'interval', :created_at => Time.now, :interval => '30', :chance => '100' )
Rule.create( :type => 'interval', :created_at => Time.now, :interval => '45', :chance => '99' )
Rule.create( :type => 'interval', :created_at => Time.now, :interval => '60', :chance => '98' )
Script.create( :name => 'on1', :text => 'turn on output 1' )
Script.create( :name => 'off1', :text => 'turn off output 1' )
Script.create( :name => 'on2', :text => 'turn on output 2' )
Script.create( :name => 'off2', :text => 'turn off output 2' )

rule = Rule.new
rule.type='tod'
rule.created_at = Time.now
rule.execute_at = '18:00'
rule.active = false
rule.chance = '130'
rule.save

script = Script.new
script.name = "test"
script.text = "empty"
script.save

# add relation
rule.script = script
rule.save

pp rule 
pp rule.script
