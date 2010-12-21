# Due to an ambiguity in the "color" of keys that start on accidentals, there is a need to define
# "color schemes", or default colors for each of the ambiguous keys, depending on the context.
#
# ColorScheme provides a way to store and access color schemes by name.  By default, there are five
# included color schemes that should be able to account for all cases, with a little fiddling with
# `flats` and `sharps`.
# 
# - `default`, for ensemble settings and "general" settings.  Mostly flat, except for C# and F#.
# - `keyboard`, for keyboard instruments.  Mostly flat, except for F#.
# - `string`, for stringed and guitar instruments.  All sharp.
# - `flats`.  Self-explanatory -- always flat.
# - `sharps`.  Self-explanatory -- always sharp.
#
# One can create a custom color scheme with
#
#     ColorScheme.create(:name => 'name of scheme', :scheme => color_array),
#
# where `color_array` is an array of twelve "colors": `nil` ("natural"), `:sharp`, or `:flat`.  All 
# "white" or natural keys should be assigned `nil`, and all accidental keys either `:sharp` or 
# `:flat`.  The keys are in ascending chromatic order from A to G#.
# 
# For example, here is the `color_array` for `keyboard`:
#
#     # A   Bb    B   C   C#     D   Eb    E   F   F#     G    Ab
#     [nil,:flat,nil,nil,:sharp,nil,:flat,nil,nil,:sharp,nil,:flat]
# 
# @author Justin Le
# 
class ColorScheme
  
  # The default key colors for the "natural", white notes.  Can be overriden on a scheme-by-scheme
  # basis, but definitely not recommended.
  @@natural_key_colors = [:sharp,nil,:sharp,:flat,nil,:sharp,nil,:flat,nil,:sharp]
  
  validates_with_block :scheme do
    @scheme.all? { |c| c.nil? or c == :sharp or c == :flat }
  end
  
  # Gets the color scheme that is "all" of a certain color.
  # 
  # @param [Symbol] `:sharp` or `:flat` -- color wanted.
  # @return [ColorScheme] The ColorScheme "sharps" or "flats", depending on what is requested.
  #
  def self.get_scheme_all(color)
    if color == :flat
      return ColorScheme.get('flats')
    elsif color == :sharp
      return ColorScheme.get('sharps')
    else
      raise ArgumentError
    end
  end
  
  # Gives the full color scheme for this scheme, naturals and accidentals included.
  # 
  # @return [Array<Symbol>] Array containing the symbol of colors in the scheme, `:sharp` or 
  #   `:flat`.
  #
  def full_scheme
    @full_scheme = (0..11).map { |n| (@scheme[n] || @@natural_key_colors[n]) } unless @full_scheme
    @full_scheme
  end
  
  # Gives the color stored in this scheme for the given SongKey.
  # 
  # @param [SongKey] song_key The key to check the for color.
  # @return [Symbol] `:sharp` or `:flat` -- symbol for the requested color.
  # 
  def color_for(song_key)
      full_scheme[render_key.key_id]
  end
  
end