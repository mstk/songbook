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
#   ambiguously.  As such, whenever rendering, a "color scheme" must be passed.  This is basically
#   a default to assign to each key, based on the context corresponding to the color scheme.  If
#   one wanted to "brute force" to a default color scheme, `:flats` and `:sharps` are available.
#   The included color schemes are:
# 
# - `:default`, for ensemble settings and "general" settings.
# - `:keyboard`, for keyboard instruments.  Mostly flat, except for F#.
# - `:string`, for stringed and guitar instruments.  All sharp.
# - `:flats`.  Self-explanatory -- always flat.
# - `:sharps`.  Self-explanatory -- always sharp.
#
# The ability to create custom color schemes is in development.
class SongKey
  
  FLAT_KEYS   = %w[ A Bb B C Db D Eb E F Gb G Ab ].map { |k| k.intern }.freeze
  SHARP_KEYS  = %w[ A A# B C C# D D# E F F# G G# ].map { |k| k.intern }.freeze
  
  KEYS = (FLAT_KEYS | SHARP_KEYS).freeze
  
  @@KEY_INDEX = Hash.new do |h,k|
    [FLAT_KEYS, SHARP_KEYS].each do |key_set|
      if key_set.include?(k)
        h[k] = SongKey.first_or_create(:key_id => key_set.index(k))
      end
    end
    h[k] = nil
  end
  
  @@color_key   = %w[ natural flat sharp ].map { |c|.intern }
  
  @@initial_color_scheme_keys = { :keyboard => [0,1,0,0,1,0,1,0,0,2,0,1],
                                  :string   => [0,2,0,0,2,0,2,0,0,2,0,2],
                                  :default  => [0,1,0,0,2,0,1,0,0,2,0,1],
                                  :flats    => [0,1,0,0,1,0,1,0,0,1,0,1], 
                                  :sharps   => [0,2,0,0,2,0,2,0,0,2,0,2] }
  
  @@initial_color_schemes = Hash.new { |h,s| h[s] = @@color_key_schemes[s].map { |c| @@color_key[c] } }
  
  @@custom_color_schemes = Hash.new
  
  # Retrieve the SongKey for a given key_symbol.
  #
  # @param [Symbol] key_symbol A key symbol from SongKey::KEYS.
  # @return [SongKey] SongKey corresponding to that key symbol.
  # 
  def SongKey.KEY(key_symbol)
    @@KEY_INDEX[key_symbol]
  end
  
  # Looks up the color scheme array for a given symbol.
  #
  # @param [Symbol] scheme_symbol Symbol representing the color scheme.
  # @return [Array<Symbol>] Color scheme, or an array of color symbols for each key.
  # 
  def SongKey.color_scheme(scheme_symbol)
    @@custom_color_schemes[scheme_symbol] || @@initial_color_schemes[scheme_symbol]
  end
  
end