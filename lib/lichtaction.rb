=begin

execute, log, edit, display commands

=end

require 'quancom-ffi'

module Licht
  class Action
    include QAPI
      #QAPI::OUT1
    def initialize
    end
  end

  class ActionStack
    def initialize
      @actions = []
    end
    def add_onCommand
    end
    def add_offCommand
    end
    def add_nameCommand
    end
    def execute
      # TODO time related, run as daemon?
    end
    def get
    end
    def modify
    end
  end
end
