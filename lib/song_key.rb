# Represents a "Key" that songs (or sections of songs) are set in.  Everything in the song is 
# described relative to a key.  SongKey is responsible for the logic of turning a given a 
# relative chord set and turning it into an absolute one.
# 
# SongKeys are represented internally by a number (from 0 to 11) that represents every key,
# chromatically, from A to G#.  Because of this, SongKeys should be accessed by using
# SongKey::KEY(symbol for key).
#
# Key Coloration
# ==========
#
# There is a slight problem with enharmonic equivalents of accidental keys, which could be rendered
# ambiguously.  As such, whenever rendering, a "color scheme" must be passed.  This is basically
# a default to assign to each key, based on the context corresponding to the color scheme.  If
# one wanted to "brute force" to a default color scheme, `:flats` and `:sharps` are available.
# 
# See ColorScheme for more information.
#
class SongKey
  
  # The steps for each note in the major scale.
  @@major_scale = [0,2,4,5,7,9,11]
  
  KEY_SET = { :flat   => %w[ A Bb B C Db D Eb E F Gb G Ab ].map { |k| k.intern },
              :sharp  => %w[ A A# B C C# D D# E F F# G G# ].map { |k| k.intern } }
  KEYS = (KEY_COLORS.values.flatten.uniq)
  
  @@major_scale.freeze
  KEY_SETS.values.each { |ks| ks.freeze }
  KEYS.freeze
  
  # Index of SongKey resources/instances for each key symbol.
  @@KEY_INDEX = Hash.new do |h,k|
    KEY_SET.values.each do |key_set|
      if key_set.include?(k)
        h[k] = SongKey.first_or_create(:key_id => key_set.index(k))
      end
    end
    h[k] = nil
  end
  
  # Given a step `n`, returns the `n+1`th scale note of the given key.
  # 
  # 
  # 
  def render_step(step,color_scheme = ColorScheme.get('default'))
    rendered_note = KEY_SET[color_scheme.full_scheme[@key_id]][(@key_id + @@major_scale[step]) % 11]
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

class KeyScale
  
  
  
end