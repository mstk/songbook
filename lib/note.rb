# Helper module to manipulate absolute note/chord symbols.
#
module Note
  
  NOTE_SET =  { :flat   => %w[ A Bb B C Db D Eb E F Gb G Ab ].map { |n| n.intern },
                :sharp  => %w[ A A# B C C# D D# E F F# G G# ].map { |n| n.intern } }
  
  def Note.note_id_for(note_symbol)
    if NOTE_SET[:flat].include? note_symbol
      return NOTE_SET[:flat].index(note_symbol)
    elsif NOTE_SET[:sharp].include? note_symbol
      return NOTE_SET[:sharp].index(note_symbol)
    else
      raise ArgumentError
    end
  end
  
  def Note.get_color_of(note_symbol)
    [:flat,:sharp].find { |a| NOTE_SET[a].include? note }
  end
  
  def Note.get_enharmonic_in_color(note_symbol,color)
    NOTE_SET[color][note_id_for(note_symbol)]
  end
  
  def Note.toggle_enharmonic(note_symbol)
    color = get_color_of(note_symbol)
    toggled_color = (color == :flat) ? :sharp : :flat
    get_enharmonic_in_color(note_symbol,toggled_color)
  end
  
end