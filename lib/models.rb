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

class Tag
  include DataMapper::Resource
  
  property :id,     Serial
  property :name,   String, :required => true
  
  has n, :songs, :through => Resource
end

class SongKey
  include DataMapper::Resource
  
  property :key_id,    Integer, :required => true, :key => true, :set => 0..11
  
  validates_uniqueness_of :key_id
  
  has n, :songs
end

class Section
  include DataMapper::Resource
  
  property :id,         Serial
  property :type,       String, :default => "CHORUS"
  property :count,      Integer, :default => 1
  property :transpose,  Integer, :default => 0
  
  belongs_to :song
  
  has n, :chord_progressions, :through => Resource
end

class ChordProgression
  include DataMapper::Resource
  
  property :id,           Serial
  property :progression,  Yaml, :required => true, :lazy => true
  # property :resolution,   Integer, :default => 1
  
  validates_uniqueness_of :progression
  
  has n, :sections, :through => Resource
end

class ColorScheme
  include DataMapper::Resource
  
  property :name,   String, :required => true, :key => true
  property :scheme, Yaml,   :required => true, :lazy => true
  
  validates_uniqueness_of :name
end