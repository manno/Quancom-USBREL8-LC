require 'data_mapper'
require 'pp'

module Webapp
  module  Model

    class Script
      include DataMapper::Resource
      property :id, Serial
      property :name, String, :default => 'name'
      property :text, Text, :default => 'turn on output 1'
      property :created_at, DateTime

      has n, :rules
    end

    class Rule
      include DataMapper::Resource
      property :id, Serial
      property :active, Boolean, :default => false

      property :type, String, :default => ''
      property :interval, String
      property :execute_at, String
      property :chance, String

      property :created_at, DateTime

      belongs_to :script, :required => false

    end

    def Model.migrate
      Script.auto_migrate! unless Script.storage_exists?
      Rule.auto_migrate! unless Rule.storage_exists?
    end

    def Model.init
      DataMapper::Logger.new($stdout, :debug) if $DEBUG
      DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/database.db")
      Model::migrate
    end

  end
end

# init database
Webapp::Model::init
