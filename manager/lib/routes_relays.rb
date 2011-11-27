module Webapp
  class RoutesRelays < MainWebApp

    get '/on/:id' do
      @daemon_client.executeAction( :on, params[:id].to_i )
      redirect '/'
    end

    get '/off/:id' do
      @daemon_client.executeAction( :off, params[:id].to_i )
      redirect '/'
    end

    get '/all_on' do
      @daemon_client.executeAction( :set_on )
      redirect '/'
    end

    get '/all_off' do
      @daemon_client.executeAction( :set_off )
      redirect '/'
    end

  end
end
