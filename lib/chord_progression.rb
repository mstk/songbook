class ChordProgression
  include DataMapper::Resource
  
  property :id,           Serial
  property :progression,  Yaml, :required => true
  # property :resolution,   Integer, :default => 1
  
  has n, :sections, :through => Resource
  
end