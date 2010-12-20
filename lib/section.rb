class Section
  include DataMapper::Resource
  
  property :id,         Serial
  property :type,       String, :default => "CHORUS"
  property :count,      Integer, :default => 1
  property :transpose,  Integer, :default => 0
  
  belongs_to :song
  
  has n, :chord_progressions, :through => Resource
end