module Webapp
  class RoutesScripts < MainWebApp

    # == FORMS

    get '/form' do
      @script = Script.new
      haml :script_edit
    end

    get '/form/:id' do
      @script = Script.get params[:id]
      haml :script_edit
    end

    get '/form/delete/:id' do
      @script = Script.get params[:id]
      haml :script_delete
    end

    # == ACTIONS

    post '/' do
      if params[:submit] == 'Submit'
        @script = Script.new
        @script.name = params[:script][:name]
        @script.text = clean_script params[:script][:text]
        @script.created_at = Time.now
        if @script.save
          set_message "successfully created script #{@script.id}.", 'success'
          redirect '/'
        else
          haml :script_edit
        end
      else
        redirect '/'
      end
    end

    post '/:id' do
      if params[:submit] == 'Submit'
        @script = Script.get params[:id]
        @script.name = params[:script][:name]
        @script.text = clean_script params[:script][:text]
        @script.created_at = Time.now
        if @script.save
          daemon_disable_active_script @script
          set_message "successfully updated script #{@script.id}."
          redirect '/'
        else
          haml :script_edit
        end
      else
        redirect '/'
      end
    end

    #delete '/script/:id' do
    post '/delete/:id' do
      if params[:submit] == 'Submit'
        @script = Script.get params[:id]
        @script.destroy
        daemon_disable_active_script @script
        set_message "successfully deleted script #{params[:id]}."
      end
      redirect '/'
    end

    # not needed, same as index
    #get '/script' do
    #  haml :script_list
    #end

    helpers do
      def clean_script( text )
        text.gsub!(/\r\n/, "\n")
        text += "\n" unless text[-1] == "\n"
        text
      end

      def daemon_disable_active_script( script )
        rules = Rule.all(:script => { :id => script.id }, :active => true)
        rules.each { |rule|
          rule.active = false
          rule.save
          @daemon_client.remove rule
        }
      end

    end
  end
end
