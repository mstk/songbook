# Helper module to manipulate absolute note/chord symbols.  Mostly dealing with enharmonic 
# conversions.
#
module Note
  
  # Set of all note symbols, categorized by color/accidental.
  NOTE_SET =  { :flat   => %w[ A Bb B C Db D Eb E F Gb G Ab ].map { |n| n.intern },
                :sharp  => %w[ A A# B C C# D D# E F F# G G# ].map { |n| n.intern } }
  
  # Finds the id of the note represented by the given note symbol.
  #
  # @param [Symbol] note_symbol
  #   Note symbol in question.
  # @return [Integer]
  #   The id of the note represented by note_symbol.
  #
  def Note.note_id_for(note_symbol)
    if NOTE_SET[:flat].include? note_symbol
      return NOTE_SET[:flat].index(note_symbol)
    elsif NOTE_SET[:sharp].include? note_symbol
      return NOTE_SET[:sharp].index(note_symbol)
    else
      raise ArgumentError
    end
  end
  
  # Finds the color/accidental of the given note symbol.
  #
  # @param [Symbol] note_symbol
  #   Note symbol in question.
  # @return [Symbol]
  #   `:sharp` or `:flat`.  If natural, will return `:flat` just for kicks (and as a default).
  #
  def Note.get_color_of(note_symbol)
    [:flat,:sharp].find { |a| NOTE_SET[a].include? note }
  end
  
  # Finds gets the enharmonic equivalent of the note in the given color/accidental.  If note is
  # natural, returns itself.
  #
  # @param [Symbol] note_symbol
  #   Note symbol to convert.
  # @param [Symbol] color
  #   `:sharp` or `:flat`.
  # @return [Symbol]
  #   The enharmonic equivalent note in the given color/accidental, or the same note if the note is
  #   natural.
  #
  def Note.get_enharmonic_in_color(note_symbol,color)
    NOTE_SET[color][note_id_for(note_symbol)]
  end
  
  # Toggles the note between its enharmonically equivalent notes by colors/accidentals.  If note is
  # natural, returns itself.
  # 
  # @param [Symbol] note_symbol
  #   Note symbol to convert.
  # @return [Symbol]
  #   The enharmonic equivalent note in the opposite color/accidental, or the same note if the note 
  #   is natural.
  #
  def Note.toggle_enharmonic(note_symbol)
    color = get_color_of(note_symbol)
    toggled_color = (color == :flat) ? :sharp : :flat
    get_enharmonic_in_color(note_symbol,toggled_color)
  end
  
end