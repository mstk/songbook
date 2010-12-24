# Represents a block of lyrics for one section of a song.
# 
# Stores an integer `variation`, describing the variation of the section the lyric is for.  For
# example, the lyrics for Verse 1 could have variation 0, and Verse 2 could have variation 1.
#
# In charge of parsing raw lyrics into the nested yaml format it is stored as, and then un-packing
# it for rendering with `Section`.
#
# @author Justin Le
# 
class Lyric
  
  def Lyric.parse(text,section,variation=0)
    lines = text.split("\n\n")
    bars = lines.map { |l| l.split("\n") }
    
    Lyric.create(:text_tree => bars, :section => section, :variation => variation)
  end
  
  def render_lines
    
    total_lines = @section.line_count
    line_lengths = @section.line_lengths
    
    output_lines = @text_tree.map { |line| line.clone }
    
    until output_lines.length >= total_lines
      output_lines += ['']
    end
    
    output_lines.length.times do |n|
      next unless line_lengths[n]
      
      until output_lines[n].length >= line_lengths[n]
        output_lines[n] += ['']
      end
      
    end
    
    output_lines
    
  end
  
end