# Represents a single Chord, stored as a number and a mode (:major or :minor).  Not actually
#   stored in the database, but rather used as a helper class for ChordProgression to help render 
#   chords into a given key in the proper color.
# Chord instances are shared across ChordProgression objects (there are only 14 possible,
#   currently), in a sort of singleton pattern.  In a way, they represent constants and are 
#   immutable.  To access the Chord instance for a given chord, use Chord::CHORD(chord symbol)
#
class Chord
  
  private_class_method :new
  
  @@roman_numerals = %w[ I II III IV V VI VII ]
  @@chord_symbols = { :major => @@roman_numerals.map { |c| c.downcase.intern },
                      :minor => @@roman_numerals.map { |c| c.intern } }
  CHORD_SYMBOLS = @@chord_symbols.values.flatten
  
  @@CHORD_INDEX = Hash.new do |h,c|
    new(c)
  end
  
  def initialize(chord_symbol)
    raise ArgumentError unless CHORD_SYMBOLS.include?(chord_symbol)
    
    @step = @@roman_numerals.index(chord_symbol.to_s.upcase.intern)
    @mode = [:major,:minor].find { |mode| mode.include? chord_symbol}
  end
  
  # Retrieve the Chord instance for a given chord_symbol.
  #
  # @param [Symbol] chord_symbol A key symbol from Chord::CHORD_SYMBOLS.
  # @return [Chord] SongKey corresponding to that chord symbol
  #
  def Chord.CHORD(chord_symbol)
    raise ArgumentError unless CHORD_SYMBOLS.include?(chord_symbol)
    
    @@CHORD_INDEX[chord_symbol]
  end
  
end