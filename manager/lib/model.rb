require 'data_mapper'
require 'pp'

module Webapp
  module  Model

    class Rule
      include DataMapper::Resource
      property :id, Serial
      property :script_id, Integer
      property :active, Boolean, :default => false
      property :type, String

      property :interval, Integer
      property :execute_at, Integer
      property :chance, Integer
      property :last, Integer

      property :created_at, DateTime

      has 1, :script

    end

    class Script
      include DataMapper::Resource
      property :id, Serial
      property :name, String
      property :text, Text
      property :created_at, DateTime

      belongs_to :rule, :required => false
    end

    def Model.migrate
      Script.auto_migrate! unless Script.storage_exists?
      Rule.auto_migrate! unless Rule.storage_exists?
    end

  end
end
