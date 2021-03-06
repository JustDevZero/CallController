# -*- coding: utf-8 -*-
class User
  include DataMapper::Resource

  def self.default_repository_name #here we use the users_db for the User objects
    :default
  end

  property :id, Serial, :key => true
  property :username, String
  property :first_name, String
  property :last_name, String
  property :email, String
  property :password, BCryptHash
  property :receive_notifications, Boolean, :default => false 
  property :token, String
  property :active, Boolean, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime
  has n, :role_members
  has n, :roles, :through => :role_members
  has n, :queue_members
  has n, :call_queues, :through => :queue_members
  has n, :agent_blacklist_members
  has n, :campaigns, :through => :agent_blacklist_members

  #~ def initialize(username, email, password, first_name='', last_name='')
    #~ begin
      #~ self.username = username
      #~ self.email = email
      #~ self.first_name = first_name
      #~ self.last_name = last_name
      #~ enc_pw = BCrypt::Password.create(password)
      #~ self.password = enc_pw
      #~ if !self.save
        #~ raise #couldn't save the object
      #~ end
    #~ rescue
      #~ return false
    #~ end
  #~ end

  def self.auth(username, password)
    un = username.to_s.downcase
    u = first(:conditions => ['lower(email) = ? OR lower(username) = ?', un, un])
    if u && u.password == password
      return u
    else
      return false
    end
  end

  def is_admin?
    is_admin = self.roles.count(:capabilities => 'admin')
    is_admin == 0 ? (return false) : (return true)
  end

  def is_agent?
    is_agent = self.roles.count(:capabilities => 'agent')
    is_agent == 0 ? (return false) : (return true)
  end

  def is_supervisor?
    is_supervisor = self.roles.count(:capabilities => 'supervisor')
    is_supervisor == 0 ? (return false) : (return true)
  end

  def is_coacher?
    is_coacher = self.roles.count(:capabilities => 'coacher')
    is_coacher == 0 ? (return false) : (return true)
  end

  def is_manager?
    is_manager = self.roles.count(:capabilities => 'manager')
    is_manager == 0 ? (return false) : (return true)
  end

end
