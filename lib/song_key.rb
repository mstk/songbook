class SongKey
  include DataMapper::Resource
  
  property :key_id,    Integer, :required => true, :key => true
  
  validates_uniqueness_of :key_id
  validates_within :key_id, (0..11)
  
  has n, :songs
end