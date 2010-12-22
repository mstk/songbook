# Represents a single Chord, stored as a number and a mode (`:major` or `:minor`).  Not actually
# stored in the database, but rather used as a helper class for ChordProgression to help render 
# chords into a given key in the proper color.
# 
# Chord instances are shared across ChordProgression objects (there are only 14 possible,
# currently), in a sort of singleton pattern.  In a way, they represent constants and are 
# immutable.  To access the Chord instance for a given chord, use Chord::CHORD(chord symbol)
# 
# @author Justin Le
# 
class Chord
  
  private_class_method :new
  
  # @private
  @@roman_numerals = %w[ I II III IV V VI VII ]
  # @private
  @@chord_symbols = { :major => @@roman_numerals.map { |c| c.intern },
                      :minor => @@roman_numerals.map { |c| c.downcase.intern } }
  CHORD_SYMBOLS = @@chord_symbols.values.flatten
  
  # @private
  @@symbol_steps = { :I => 0, :II => 2, :III => 4, :IV => 5, :V => 7, :VI => 9, :VII => 11 }
  # @private
  @@step_symbols = [:I,nil,:ii,nil,:iii,:IV,nil,:V,nil,:vi,nil,:vii]
  
  # @private
  @@CHORD_INDEX = Hash.new do |h,c|
    new(c)
  end
  
  # @private
  @@mode_render = { :major => "", :minor => "m" }
  
  # Renders the chord to the given key, with the given color scheme.
  # 
  # @param [SongKey] song_key
  #   SongKey of the key to render the chord into.
  # @param [ColorScheme] color_scheme
  #   ColorScheme to follow.  See ColorScheme for more info.  Optional (defaults to the default 
  #   color scheme).
  # @return [Symbol]
  #   An absolute chord symbol corresponding to the chord rendered to the given SongKey and given 
  #   ColorScheme.
  # 
  def render_into(song_key,color_scheme = ColorScheme.get('default'))
    "#{song_key.transpose(@modulation).render_step(@step,color_scheme)}#{@@mode_render[@mode]}".intern
  end
  
  # Retrieve the Chord instance for a given chord_symbol.
  #
  # @param [Symbol] chord_symbol
  #   A chord symbol from Chord::CHORD_SYMBOLS.
  # @return [Chord]
  #   SongKey corresponding to that chord symbol
  #
  def Chord.CHORD(chord_symbol)
    # validation
    Chord.extract_chords(chord_symbol)
    
    @@CHORD_INDEX[chord_symbol]
  end
  
  # Retrieve the chord symbol for this Chord instance.
  #
  # @return [Symbol]
  #   The symbol representing the roman-numeral relative value of the chord
  #
  def symbol
    if @modulation == 0
      @@chord_symbols[@mode][@step]
    else
      "#{@@chord_symbols[@mode][@step]}/#{@@step_symbols[@modulation]}".intern
    end
  end
  
  # Initialize a new Chord instance with a given chord_symbol.  Private method, and should only be
  # done by `@@CHORD_INDEX` hash lambda, to maintain singleton pattern.
  #
  # @param [Symbol] chord_symbol
  #   Symbol of the chord to convert.
  # 
  # @private
  # 
  def initialize(chord_symbol)
    chord_part, mod_part = Chord.extract_chords(chord_symbol)
    
    @mode = [:major,:minor].find { |mode| @@chord_symbols[mode].include? chord_part }
    @step = @@chord_symbols[@mode].index(chord_part)
    @modulation = @@symbol_steps[mod_part.to_s.upcase.intern]
  end
  
  # Helper method to extract the chord and modulation from a given chord symbol.  Also validates.
  #
  # @param [Symbol] chord_symbol
  #   Symbol of the chord symbol to be parsed.
  # @return [Array(Symbol,Symbol)]
  #   An array containing first the chord part, then the modulation part.
  # 
  def Chord.extract_chords(chord_symbol)
    chord_string = chord_symbol.to_s
    chord_string += "/I" unless chord_string.include?("/")
    
    chord_part, mod_part = chord_string.split("/").map { |c| c.intern }
    
    raise ArgumentError unless CHORD_SYMBOLS.include? chord_part
    raise ArgumentError unless CHORD_SYMBOLS.include? mod_part
    
    return [chord_part, mod_part]
  end
  
end