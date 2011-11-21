module Webapp
  class RoutesRules < MainWebApp

    # == FORMS

    get '/form' do
      @data = {
        :type => 'clear',
        :interval_chance => '100',
        :interval_interval => '15',
        :pit_chance => '100',
        :pit_execute_at => '2010-12-31 18:00',
        :tod_chance => '100',
        :tod_execute_at => '18:00',
      }
      haml :rule_edit
    end

    get '/form/:id' do
      @rule = Rule.get params[:id]
      @data = get_form_from_rule @rule
      haml :rule_edit
    end

    get '/form/delete/:id' do
      @rule = Rule.get params[:id]
      haml :rule_delete
    end

    get '/form/assign/:id' do
      @rule = Rule.get params[:id]
      @scripts = Script.all
      haml :rule_assign
    end

    # == ACTIONS

    post '/' do
      if params[:submit] == 'Submit'
        @rule = Rule.new
        update_rule_from_form @rule, params[:data]
        set_message "successfully created rule #{@rule.id}."
      end
      redirect '/'
    end

    post '/:id' do
      if params[:submit] == 'Submit'
        @rule = Rule.get params[:id]
        update_rule_from_form @rule, params[:data]
        daemon_disable_rule @rule
        set_message "successfully updated rule #{@rule.id}."
      end
      redirect '/'
    end

    #delete '/rule/:id' do
    post '/delete/:id' do
      # remove rule from daemon if active
      if params[:submit] == 'Submit'
        @rule = Rule.get params[:id]
        daemon_disable_rule @rule
        @rule.destroy
        set_message "successfully deleted rule #{params[:id]}."
      end
      redirect '/'
    end

    #post '/assign/:id' do
    get '/assign/:id/:script_id' do
      @rule = Rule.get params[:id]
      @script = Script.get params[:script_id]
      @rule.script = @script
      @rule.save
      daemon_disable_rule @rule
      set_message "successfully assigned rule #{@rule.id} to script #{@script.id}"
      redirect "/"
    end

    #post '/toggle/:id' do
    get '/toggle/:id' do
      @rule = Rule.get params[:id]
      # FIXME access to script?
      if @rule.script.nil?
        set_message "missing script, can't activate", 'error'
        redirect "/"
      end
      if @rule.active
        set_message "deactivated rule #{@rule.id}"
        @daemon_client.remove @rule
      else
        set_message "activated rule #{@rule.id}"
        @daemon_client.add @rule
      end
      @rule.active = ! @rule.active
      @rule.save

      redirect "/"
    end

    # not needed, same as index
    # get '/rule' do
    #   haml :rule_list
    # end

    # no use
    # get '/:id' do
    #   @rule = Rule.get params[:id]
    #   # return xml?
    # end
    # == Helpers

    helpers do
  
      def daemon_disable_rule( rule )
        if rule.active
          rule.active = false
          @daemon_client.remove rule
        end
      end

      def update_rule_from_form( rule, params )
        type = params[:type]
        unless %w{clear interval pit tod}.include? type
          type = 'clear'
        end
        rule.type = type
        rule.created_at = Time.now

        case type
        when 'interval'
          rule.chance = params[:interval_chance]
          rule.interval = params[:interval_interval]
        when 'pit'
          rule.chance = params[:pit_chance]
          rule.execute_at = params[:pit_execute_at]
        when 'tod'
          rule.chance = params[:tod_chance]
          rule.execute_at = params[:tod_execute_at]
        end
        rule.save
      end

      def get_form_from_rule( rule )
        data = {
          :type => rule.type,
        }
        case rule.type
        when 'interval'
          data[:interval_chance] = rule.chance
            data[:interval_interval] = rule.interval
        when 'pit'
          data[:pit_chance] = rule.chance
            data[:pit_execute_at] = rule.execute_at
        when 'tod'
          data[:tod_chance] = rule.chance
            data[:tod_execute_at] = rule.execute_at
        end
        data
      end

    end

  end
end
