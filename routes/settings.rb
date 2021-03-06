# -*- coding: utf-8 -*-
class CallController < Sinatra::Application
  get '/settings' do
    if user.is_admin?
      @callresults = CallResult.all
      cfg = Email.first_or_create
      @method = cfg.method
      @path = cfg.path
      @host = cfg.host
      @port = cfg.port
      @tls = cfg.tls
      @user = cfg.user ? cfg.user : ""
      @password = cfg.password ? Base64.decode64(cfg.password) : ""
      @disclaimer = false
      if !Gem::Specification::find_all_by_name('viewpoint').any?
        @disclaimer = true
      end
      erb :'system/system_settings'
    else
      not_found
    end
  end

  post '/settings/default' do
    Settings.first_or_create('defaultcall', params['default_call_result_id'])
  end
  
  post '/settings/email' do
    if user.is_admin?
      cfg = Email.all.first
      if params['method'] == "sendmail"
        cfg.method = :sendmail
        cfg.path = params['path']
      elsif params['method'] == "smtp"
        cfg.method = :smtp
        cfg.host = params['host']
        cfg.port = params['port']
        if params['tls'].nil?
          cfg.tls = false
        else
          cfg.tls = true
        end
        cfg.user = params['user']
        cfg.password = Base64.encode64(params['password'])
      elsif params['method'] == "exchange"
        cfg.method = :exchange
        cfg.host = params['host']
        cfg.user = params['user']
        cfg.password = Base64.encode64(params['password'])
      end
      cfg.save
      redirect to "/settings"
    else
      not_found
    end
  end
end
