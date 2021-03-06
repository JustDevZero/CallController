# -*- coding: utf-8 -*-
class Email
  include DataMapper::Resource


  SMTP_ERRORS = [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
                 Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
                 Errno::ECONNREFUSED, Net::SMTPSyntaxError, Net::SMTPFatalError]

  SSL_ERRORS = [OpenSSL::SSL::SSLError]

  def self.default_repository_name #here we use the hosts_db for the Host objects
   :default
  end

  property :id, Integer, :default => 1, :key => true  # we just store one object, but key property is needed
  property :method, Enum[ :sendmail, :smtp, :exchange ], :default => :sendmail
  property :path, String, :default => "/usr/sbin/sendmail"
  property :host, String, :default => "localhost"
  property :port, String, :default => "587"
  property :tls, Boolean, :default => true
  property :user, String
  property :password, String

  def self.mail(to_, subject_, body_)
    begin
      cfg = Email.all.first
      if cfg.method != :exchange
        mail = Mail.new do
          to to_
          from cfg.user
          subject subject_
          text_part do
            body body_
          end
        end
        if cfg.method == :smtp
          mail.raise_delivery_errors = true
          cfg_password = Base64.decode64(cfg.password)
          # setting open_ssl_verify_mode to true, makes mail to use the SSL, if it's valid or self-signed
          # Maybe, in future we should verify it, but the info is a bit obscure: http://www.rubydoc.info/github/meskyanichi/backup/Backup/Notifier/Mail#openssl_verify_mode-instance_method
          mail.delivery_method :smtp, address: cfg.host, port: cfg.port.to_i, user_name: cfg.user, password: cfg_password, authentication: 'plain', enable_starttls_auto: cfg.tls, return_response: true, openssl_verify_mode: "none"
          mail.deliver!

        elsif cfg.method == :sendmail
          mail.delivery_method :sendmail, :location => cfg.path
          mail.deliver!
        end
      elsif cfg.method == :exchange
        if Gem::Specification::find_all_by_name('viewpoint').any?
          require 'viewpoint'
          endpoint = cfg.host
          ews_user = cfg.user
          ews_pass = Base64.decode64(cfg.password)
          ews_cli = Viewpoint::EWSClient.new endpoint, ews_user, ews_pass
          ews_cli.send_message subject: subject_, body: body_, to_recipients: [ to_ ]
        end
      end
    rescue *SMTP_ERRORS => e
      Notification.create(:type => :error, :sticky => false, :message => "Email error: "+e.message)
      return false
    rescue *SSL_ERRORS => e
      Notification.create(:type => :error, :sticky => false, :message => "Email error: "+e.message)
      return false
    rescue => e
      Notification.create(:type => :error, :sticky => false, :message => "Email error: "+e.message)
      return false
    end
  end
end
