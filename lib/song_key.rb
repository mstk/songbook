# Represents a "Key" that songs (or sections of songs) are set in.  Everything in the song is 
#   described relative to a key.  SongKey is responsible for the logic of turning a given a 
#   relative chord set and turning it into an absolute one.
# SongKeys are represented internally by a number (from 0 to 11) that represents every key,
#   chromatically, from A to G#.  Because of this, SongKeys should be accessed by using
#   SongKey::KEY(symbol for key).
#
# Key Coloration
# ==========
#
# There is a slight problem with enharmonic equivalents of accidental keys, which could be rendered
#   ambiguously.  As such, whenever rendering, `:flat` or `:sharp` must be passed in order to
#   specify which way to "color" the output.  Choices can make a large difference depending on the 
#   context/instrument.  In general, String instruments should be Sharp, and Keyboard instruments
#   should be Flat, but there are subtleties involved.
# A default "color scheme" is provided, along with two other nice settings.  This, combined with
#   the `:flats` and `:sharps` color schemes (all flat and all sharp, respectively), should be able
#   to cover all possible scenarios for now, with a little hacking.  However, a way to implement 
#   custom color schemes should be implemented.
#
class SongKey
  
  @@flat_keys   = %w[ A Bb B C Db D Eb E F Gb G Ab ].map { |k| k.intern }
  @@sharp_keys  = %w[ A A# B C C# D D# E F F# G G# ].map { |k| k.intern }
  @@color_key   = %w[ natural flat sharp ].map { |c|.intern }
  
  @@color_key_schemes = { :keyboard => [0,1,0,0,1,0,1,0,0,2,0,1],
                          :string   => [0,2,0,0,2,0,2,0,0,2,0,2],
                          :default  => [0,1,0,0,2,0,1,0,0,2,0,1],
                          :flats    => [0,1,0,0,1,0,1,0,0,1,0,1], 
                          :sharps   => [0,2,0,0,2,0,2,0,0,2,0,2] }
  
  COLOR_SCHEMES = Hash.new { |h,s| h[s] = @@color_key_schemes[s].map { |c| @@color_key[c] } }
  
  KEYS = FLAT_KEYS | SHARP_KEYS
  
  @@KEY_INDEX = Hash.new do |h,k|
    [@@flat_keys, @@sharp_keys].each do |key_set|
      if key_set.include?(k)
        h[k] = SongKey.first_or_create(:key_id => key_set.index(k))
      end
    end
    h[k] = nil
  end
  
  # Retrieve the SongKey for a given key_symbol.
  #
  # @param [Symbol] key_symbol A key symbol from SongKey::KEYS.
  # @return [SongKey] SongKey corresponding to that key symbol.
  #
  def SongKey.KEY(key_symbol)
    @@KEY_INDEX[key_symbol]
  end
  
end