# Represents a "Key" that songs (or sections of songs) are set in.  Everything in the song is 
# described relative to a key.  SongKey is responsible for the logic of turning a given a 
# relative chord set and turning it into an absolute one.
# 
# SongKeys are represented internally by a number (from 0 to 11) that represents every key,
# chromatically, from A to G#.  Because of this, SongKeys should be accessed by using
# SongKey::KEY(symbol for key).
#
# Key Coloration/Accidentals
# ==========
#
# There is a slight problem with enharmonic equivalents of accidental keys, which could be rendered
# ambiguously.  As such, whenever rendering, a "color scheme" must be passed.  This is basically
# a default to assign to each key, based on the context corresponding to the color scheme.  If
# one wanted to "brute force" to a default color scheme, `:flats` and `:sharps` are available.
# 
# See ColorScheme for more information.
# 
# @author Justin Le
# 
class SongKey
  
  # The set of all valid key symbols, split by color.
  KEY_SET = { :flat   => %w[ A Bb B C Db D Eb E F Gb G Ab ].map { |k| k.intern },
              :sharp  => %w[ A A# B C C# D D# E F F# G G# ].map { |k| k.intern } }
  
  # An array containing all valid key symbols.
  KEYS = (KEY_SET.values.flatten.uniq)
  
  KEY_SET.values.each { |ks| ks.freeze }
  KEYS.freeze
  
  # Index of SongKey resources/instances for each key symbol.
  #
  # @private
  #
  @@KEY_INDEX = Hash.new do |h,k|
    if KEY_SET[:flat].include? k
      h[k] = SongKey.first_or_create(:key_id => KEY_SET[:flat].index(k))
    elsif KEY_SET[:sharp].include? k
      h[k] = SongKey.first_or_create(:key_id => KEY_SET[:sharp].index(k))
    else
      h[k] = nil
    end
  end
  
  # Retrieve the SongKey for a given key_symbol.
  #
  # @param [Symbol] key_symbol A key symbol from SongKey::KEYS.
  # @return [SongKey] SongKey corresponding to that key symbol.
  # 
  def SongKey.KEY(key_symbol)
    raise ArgumentError unless KEYS.include? key_symbol
    @@KEY_INDEX[key_symbol]
  end
  
  # Given a step `n`, returns the `n+1`th scale note of the given key.  Basically, "rendering"
  # the relative step into an absolute one.
  # 
  # @param [Integer] step
  #   Number of steps from the root note, along the major scale.  Should be between 0 and 7, but 
  #   will still work if not.
  # @param [ColorScheme] color_scheme
  #   The ColorScheme/accidental patten of the key to render the step into.
  # @return [Symbol]
  #   A symbol representing the absolute chord.
  #
  def render_step(step,color_scheme = ColorScheme.get('default'))
    scale(color_scheme)[step]
  end
  
  # Returns the key symbol for this key within the given color scheme.
  # 
  # @param [ColorScheme] color_scheme
  #   The color scheme/accidental patten of the key to render the key into.
  # @return [Symbol]
  #   A symbol representing the key.
  # 
  def symbol(color_scheme = ColorScheme.get('default'))
    KEY_SET[color_scheme.color_for(self)][@key_id]
  end
  
  # Gets the major scale for the key, within a given color scheme.  Caches result based on color.
  # 
  # @param [ColorScheme] color_scheme
  #   The color scheme/accidental patten of the key to render the scale into.
  # @return [Array<Symbol>]
  #   An array with the symbol of the absolute note value for each step, in
  #   this key.
  # 
  def scale(color_scheme = ColorScheme.get('default'))
    unless @scales
      @scales = { :flat  => ScaleGenerator::generate_scale(self,:flat),
                  :sharp => ScaleGenerator::generate_scale(self,:sharp) }
    end
    
    @scales[color_scheme.color_for(self)]
  end
  
  # Returns the result of transposing this key by the given number of steps.
  #
  # @param [Integer] steps
  #   The number of steps to transpose by.  Can be positive or negative.
  # @return [SongKey]
  #   SongKey that is `steps` steps above this SongKey.
  #
  def transpose(steps)
    SongKey.first_or_create(:key_id => (@key_id + steps) % 12)
  end
  
  def difference(other_key)
    other_key.key_id - key_id
  end
  
end