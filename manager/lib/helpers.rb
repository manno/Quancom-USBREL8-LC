module Webapp
  module Helpers

    def type_to_name( type )
      case type
      when 'interval'
        "Interval"
      when 'pit'
        "Specific Date"
      when 'tod'
        "Daily"
      else
        ""
      end
    end

    def set_message( msg, style='success' )
      session[:message] = msg
      session[:message_style] = style
    end

    def get_message
      @message = session[:message]
      @message_style = session[:message_style]
      set_message ""
    end

  end
end
