# Represents a single Chord, stored as a number and a mode (`:major` or `:minor`).  Not actually
# stored in the database, but rather used as a helper class for ChordProgression to help render 
# chords into a given key in the proper color.
# 
# Chord instances are shared across ChordProgression objects (there are only 14 possible,
# currently), in a sort of singleton pattern.  In a way, they represent constants and are 
# immutable.  To access the Chord instance for a given chord, use Chord::CHORD(chord symbol)
# 
# Chord symbols are in the form `:"I-mod1-mod2..._inversion"`, where modifiers are arbitrary 
# strings like "7" and "sus".  Inversions are integers representing the scale degree that is the 
# bass note.  This is different from figured bass convention, but seems more natural to me.
# 
# @note
#   Please avoid modifiers and inversions whenever possible, unless they significantly change the
#   character of the chord progression.
#
# @note
#   Modifiers don't actually "do" anything at the moment.  They're just dumb strings for the most
#   part.  The one exception is "\*" (diminished), which changes the scale used when finding 
#   inversion notes.  "+" (augmented) is dumb for now.  Please don't use it with inversions.
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
  
  # All valid chord symbols
  CHORD_SYMBOLS = @@chord_symbols.values.flatten
  
  # @private
  @@CHORD_INDEX = Hash.new do |h,c|
    h[c] = new(c)
  end
  
  # @private
  @@mode_render = { :major => "", :minor => "m" }
  
  # Retrieve the Chord instance for a given chord_symbol.
  #
  # @param [Symbol] chord_symbol
  #   A chord symbol from Chord::CHORD_SYMBOLS.
  # @return [Chord]
  #   SongKey corresponding to that chord symbol
  #
  def Chord.CHORD(chord_symbol)
    @@CHORD_INDEX[chord_symbol]
  end
  
  def Chord.RELATIVE(absolute_chord_symbol,song_key)
    chord_string = absolute_chord_symbol.to_s
    
    note_end = (chord_string[1] == 'b' || chord_string[1] == '#') ? 1 : 0
    mode_end = note_end + ((chord_string[note_end+1] == 'm') ? 1 : 0)
    
    note = chord_string[0..note_end]
    mode = chord_string[mode_end] == 'm' ? :minor : :major
    tail = chord_string[mode_end+1..-1]
    tail += "/#{note}" unless tail.include? '/'
    mod_string,inversion = tail.split('/')
    mods = mod_string.split('-')
    
    difference = song_key.difference(SongKey.KEY(note.intern))
    
    chord_symbol = %w[ I II II III III IV V V VI VI VII VII][difference]
    sub = [false,true,false,true,false,false,true,false,true,false,true,false][difference]
    
    chord_symbol.downcase! if mode == :minor
    
    if inversion != note
      scale_mode = mode
      
      chord_scale_flat = ScaleGenerator::generate_scale( SongKey.KEY(note.intern) , :flat , mode )
      chord_scale_sharp = ScaleGenerator::generate_scale( SongKey.KEY(note.intern) , :sharp , mode )
      
      # ignore inversions not in scale
      inversion_num = chord_scale_flat.index(inversion.intern) || chord_scale_sharp.index(inversion.intern) || 0
      
      inversion_string = "_#{inversion_num+1}"
    else
      inversion_string = ''
    end
    
    mod_string = mods.empty? ? '' : "-#{mods * "-"}"
    
    return Chord.CHORD("#{sub ? 'b' : ''}#{chord_symbol}#{mod_string}#{inversion_string}".intern)
  end
  
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
    if @sub
      render_color = color_scheme.color_for(song_key)
      render_key = song_key.transpose(-1)
      rendered_chord_note_raw = render_key.render_step(@step,color_scheme)
      rendered_chord_note = Note::get_enharmonic_in_color(rendered_chord_note_raw,render_color)
    else
      rendered_chord_note = song_key.render_step(@step,color_scheme)
    end
    
    mode_str = @@mode_render[@mode]
    
    modifiers_str = @modifiers * '-'
    
    if @inversion > 1
      
      scale_mode = @mode
      scale_mode = :locrian if @modifiers.include? "*"
      # @todo implement augmented. lol ya right. nvm.
      
      chord_scale = ScaleGenerator::generate_scale( SongKey.KEY(rendered_chord_note) , color_scheme.color_for(song_key) , scale_mode )
      
      inversion_str = "/#{chord_scale[@inversion-1]}"
    else
      inversion_str = ""
    end
    
    "#{rendered_chord_note}#{mode_str}#{modifiers_str}#{inversion_str}".intern
  end
  
  # Retrieve the chord symbol for this Chord instance.
  #
  # @return [Symbol]
  #   The symbol representing the roman-numeral relative value of the chord
  # 
  def symbol
    sub_str       = @sub ? "b" : ""
    chord_str     = @@chord_symbols[@mode][@step]
    modifiers_str = @modifiers.empty? ? "" : "-#{@modifiers * "-"}"
    inversion_str = @inversion > 1 ? "_#{@inversion}" : ""
    
    "#{sub_str}#{chord_str}#{modifiers_str}#{inversion_str}".intern
  end
  
  # Whether or not the chord is a sub chord. (modulation one half-step down)
  #
  # @return [Boolean]
  #   true if it is, false if it is not.
  # 
  def is_sub?
    @sub
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
    
    chord_symbol_str = chord_symbol.to_s
    chord_symbol_str += "_1" unless chord_symbol_str.include? "_"
    
    chord_with_mods,inversion_str = chord_symbol_str.split("_")
    
    chord_part_str,*@modifiers = chord_with_mods.to_s.split("-")
    
    if chord_part_str[0] == "b"
      @sub = true
      chord_part = chord_part_str[1..-1].intern
    else
      @sub = false
      chord_part = chord_part_str.intern
    end
    
    raise ArgumentError unless CHORD_SYMBOLS.include? chord_part
    
    inversion_number = inversion_str.to_i
    
    # validate for valid inversion
    raise ArgumentError unless inversion_number > 0
    
    # some math to "reduce" the inversion to its lowest equivalent
    @inversion = (inversion_number - 1) % 7 + 1
    
    @mode = [:major,:minor].find { |mode| @@chord_symbols[mode].include? chord_part }
    @step = @@chord_symbols[@mode].index(chord_part)
  end
  
end