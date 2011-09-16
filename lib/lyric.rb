# Represents a block of lyrics for one section of a song.
# 
# Stores an integer `variation`, describing the variation of the section the lyric is for.  For
# example, the lyrics for Verse 1 could have variation `1`, and Verse 2 could have variation `2`.
#
# In charge of parsing raw lyrics into the nested yaml format it is stored as, and then un-packing
# it for rendering with `Section`.
#
# @author Justin Le
# 
class Lyric
  
  # Parses a string of lyrics, with its section and variation #, into a Lyric resource.
  # 
  # @param [String,Array<Array<String>>] text
  #   Text formatted with
  #   - One newline after every chord change (NOT every measure, or half note, or other unit)
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
  #       God who's come to bring us back to him
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
  def Lyric.build(text,section,variation=1,includes_invisible = false)
    bars = Lyric.process_raw(text)
    
    lyric = Lyric.create(:text_tree => bars, :section => section, :variation => variation)
    
    unless includes_invisible
      lyric.update_to_section
    end
    
    section.lyrics << lyric
    section.save
    
    lyric
  end
  
  def Lyric.process_raw(text)
    lines = text.split("\n\n")
    bars = lines.map { |l| l.split("\n") }
    
    bars.length.times do |n|
      
      # make sure all lyric blocks have a space at the end, except for hyphenated ones,
      # and that blank blocks are blank strings
      bars[n].map! do |b|
        next b if b == ''
        next b if b[-1] == "-"
        next (b + " ") if b[-1] != ' '
        next '' if b == ' '
        next b
      end
      
      # make sure the last section block does not have a space at the end
      if bars[n][-1][-1] == ' '
        bars[n][-1] = bars[n][-1].squeeze(" ")[0..-2]
      end
      
    end
    
    return bars
  end
  
  def Lyric.blank_lyric(section,variation=1)
    Lyric.build("",section,variation,false)
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
    
    total_lines = section.line_count
    line_lengths = section.line_lengths
    
    output_lines = text_tree.map { |line| line.clone }
    
    # pad new lines to match the number of chord progressions
    until output_lines.length >= total_lines
      output_lines << ''
    end
    
    output_lines.length.times do |n|
      next unless line_lengths[n]
      
      # fill line to match the number of chord changes
      until output_lines[n].length >= line_lengths[n]+1
        output_lines[n] << ''
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
  
  def is_empty?
    !text_tree.any? { |line| line.any? { |block| block.length > 0 && block.squeeze(' ') != ' ' } }
  end
  
  def update_to_section
    
    chords_summary = section.render_chords
    
    curr_line = 0
    
    bars = text_tree.map do |line|
      
      curr_block = 1
      line_out = [line[0]]
      
      summary_line = chords_summary[curr_line]
      
      summary_line.each do |b|
        if b == :''
          line_out << ''
        else
          line_out << (line[curr_block] || '')
          curr_block += 1
        end
      end
      
      curr_line += 1
      
      next line_out
    end
    
    text_tree = bars
    
    save
  end
  
  def delete_line(line_num)
    text_tree.delete_at(line_num)
    save
  end
  
  def change_lyrics(line_num,new_lyric)
    new_line = Lyric.process_raw(new_lyric)
    
    raise "hey, you can't do #{new_line.to_yaml}." if new_line.size != 1
    
    text_tree[line_num] == new_line[0]
    
    update_to_section
  end
  
end