# -*- coding: utf-8 -*-
class Notification
  include DataMapper::Resource

  def self.default_repository_name #here we use the tasks_db for the Notification objects
    :default
  end

  property :id, Serial
  property :type, Enum[ :error, :info, :success ], :lazy => false
  property :message, Text, :lazy => false
  property :sticky, Boolean, :default => false, :lazy => false
  property :dismiss, Boolean, :default => false, :lazy => false
  property :created_at, DateTime
  property :updated_at, DateTime
  property :inclass, Discriminator
  
end
