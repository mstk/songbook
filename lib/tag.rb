class Tag
  include DataMapper::Resource
  
  property :id,     Serial
  property :name,   String, :required => true
  
  has n, :songs, :through => Resource
end