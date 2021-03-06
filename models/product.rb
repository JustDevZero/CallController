class Product
  include DataMapper::Resource
  
  def self.default_repository_name #here we use the users_db for the User objects
    :default
  end
  
  property :id, Serial, :key => true
  property :external_id, String
  property :name, String
  property :created_at, DateTime
  property :updated_by, Integer
  property :updated_at, DateTime
  
end
