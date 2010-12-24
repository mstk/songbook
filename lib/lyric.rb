# Represents a block of lyrics for one section of a song.
# 
# Stores an integer `variation`, describing the variation of the section the lyric is for.  For
# example, the lyrics for Verse 1 could have variation `0`, and Verse 2 could have variation `1`.
#
# In charge of parsing raw lyrics into the nested yaml format it is stored as, and then un-packing
# it for rendering with `Section`.
# 
# @todo find a better scheme to parse lyrics from.
#
# @author Justin Le
# 
class Lyric
  
  # Parses a string of lyrics, with its section and variation #, into a Lyric resource.
  # 
  # @param [String,Array<Array<String>>] text
  #   Text formatted with
  #   - One newline after every chord change
  #   - Two newlines in a row between every line
  #   - "Empty" chord changes should have a space between each newline to disambiguate from line
  #     changes.
  #   - Chord changes in a line can be ignored after the last one that splits a lyric.
  #   - Don't forget the leading chord change/newline.
  #   - Capitalize naturally, in sentences.
  #
  #   Example:
  #
  #       Here is our
  #       King, here is our
  #       Love, here is our
  #       God who's come to
  #       bring us back to him
  #       
  #       (one space on this line)
  #       He is the one
  #       He is Je-
  #       sus
  #   
  #   However, if an actual pre-parsed lyric tree is passed (an array of array of strings), this 
  #   will just use that instead.
  # @param [Section] section
  #   The song section that this lyric is attached to.
  # @param [Integer] variation
  #   Arbitrary number representing the "variation" number of the lyrical block for the section.
  #   See class overview.
  # @return [Lyric]
  #   A parsed Lyric resource.
  # 
  def Lyric.build(text,section,variation=0)
    lines = text.split("\n\n")
    bars = lines.map { |l| l.split("\n") }
    
    lyric = Lyric.create(:text_tree => bars, :section => section, :variation => variation)
    
    section.lyrics << lyric
    section.save
    
    lyric
  end
  
  # Renders the lines of texts into an array of lines.  Lines are represented by an array of 
  # strings, split up by chord changes.  Chord changes with no text in between them are accounted
  # for, and so are empty lines.
  # 
  # @return [Array<Array<String>>]
  #   Array of lines, which are themselves arrays split by chord changes.  Blank chord changes and
  #   lines included.
  #
  def render_lines
    
    total_lines = @section.line_count
    line_lengths = @section.line_lengths
    
    output_lines = @text_tree.map { |line| line.clone }
    
    until output_lines.length >= total_lines
      output_lines += [[" "]]
    end
    
    output_lines.length.times do |n|
      next unless line_lengths[n]
      
      until output_lines[n].length >= line_lengths[n]+1
        output_lines[n] += [" "]
      end
      
    end
    
    output_lines
    
  end
  
  # Iterates through the rendered lines of this lyrical block.
  # 
  # @return [Array<String>]
  #   Lyrical lines, which are themselves arrays split by chord changes.  Blank chord changes and
  #   lines included.
  # 
  def each_rendered_line
    render_lines.each { |l| yield l }
  end
  
end