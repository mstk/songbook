# Due to an ambiguity in the "color" of keys that start on accidentals, there is a need to define
# "color schemes", or default colors for each of the ambiguous keys, depending on the context.
#
# ColorScheme provides a way to store and access color schemes by name.  By default, there are five
# included color schemes that should be able to account for all cases, with a little fiddling with
# `:flats` and `:sharps`.
# 
# - `:default`, for ensemble settings and "general" settings.  Mostly flat, except for C# and F#.
# - `:keyboard`, for keyboard instruments.  Mostly flat, except for F#.
# - `:string`, for stringed and guitar instruments.  All sharp.
# - `:flats`.  Self-explanatory -- always flat.
# - `:sharps`.  Self-explanatory -- always sharp.
#
# One can create a custom color scheme with
#
#     ColorScheme.create(:name => 'name of scheme', :scheme => color_array),
#
# where `color_array` is an array of twelve "colors": `nil` ("natural"), `:sharp`, or `:flat`.  All 
# "white" or natural keys should be assigned `nil`, and all accidental keys either `:sharp` or 
# `:flat`.  The keys are in ascending chromatic order from A to G#.
#
# For example, here is the `color_array` for `:keyboard`:
#
#     # A   Bb    B   C   C#     D   Eb    E   F   F#     G    Ab
#     [nil,:flat,nil,nil,:sharp,nil,:flat,nil,nil,:sharp,nil,:flat]
#
class ColorScheme
  
  @@natural_key_colors = [:sharp,nil,:sharp,:flat,nil,:sharp,nil,:flat,nil,:sharp]
  
  validates_with_block :scheme do
    @scheme.all? { |c| c.nil? or c == :sharp or c == :flat }
  end
  
  # yeah
  #
  #
  def full_scheme
    (0..11).map { |n| @scheme[n] || @@natural_key_colors[n] }
  end
  
end