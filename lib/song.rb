class Song
  include DataMapper::Resource
  
  property :id,             Serial
  property :title,          String, :required => true
  property :artist,         String, :default => "(no artist)"
  property :time_signature, String, :default => "4/4"
  property :comment,        Text
  property :created_on,     Date
  
  belongs_to :song_key
  
  has n, :sections
  
  has n, :tags, :through => Resource
end