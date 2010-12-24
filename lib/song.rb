# Represents a song, containing meta data, sections, a song_key, and an important `structure` array
# which encodes the structure of the song, and what order to arrange the sections in.
#
# An entry in the `structure` array consists of:
# 
# - `:type`, the section type.  Required.
# - `:variation`, the variation of the section type (ie, for two different choruses).  By default, 1.
# - `:modulation`, the modulation of the given section from the rest of the song.  By default, 0.
# - `:lyric_variation`, the variation of lyric to use.  For example, Verse 1 and Verse 2.  By default, 1.
# - `:repeat`, the number of times to repeat the section in a row.  By default, 1.
#
# @author Justin Le
#
# @todo add ability to only render certain sections of the song
#
class Song
  
  # Interprets one section in the `structure` array.  Basically fills out and extrapolates missing
  # parameters/options.  Returns the filled-out hash.
  #
  # @param [Hash] A hash in the `structure` array containing specific section detail.
  # @return [Hash] The same hash, but filled out with all default and interpolated values.
  #
  def Song.structure_interpreter(params)
    raise ArgumentError unless params[:type]
    
    type                  = params[:type]
    variation             = params[:variation] || 1
    modulation            = params[:modulation] || 0
    lyric_variation       = params[:lyric_variation] || 1
    render_section_number = params[:lyric_variation] ? true : false
    repeat                = params[:repeat] || 1
    
    { :type                   => type,
      :variation              => variation,
      :modulation             => modulation,
      :lyric_variation        => lyric_variation,
      :render_section_number  => render_section_number,
      :repeat                 => repeat }
  end
  
  # Returns an array based on the `structure` array giving each section with its title and its
  # lines.
  #
  # @param [SongKey,Integer] key_modifier
  #   If an integer, the modulation from the original key.  If a SongKey, the alternate key to 
  #   render the song into.  If nil, the song's true key is used.
  # @return [Array<Hash>]
  #   An array with an entry for each section.  Each section is a hash, containing:
  #
  #   - `:title`, the title of the section
  #   - `:lines`, the lines in the section
  #
  #   The lines themselves are arrays, with one entry for each line.  Each entry is a hash,
  #   containing:
  #
  #   - `:chords`, a list of chords on that line.
  #   - `:lyrics`, an array containing the lyrics for that line, split by chord change.
  #
  def render_sections(key_modifier = nil)
    
    # find render key
    if key_modifier
      if key_modifier.class == SongKey
        render_key = key_modifier
      else
        render_key = song_key.transpose(key_modifier)
      end
    else
      render_key = song_key
    end
    
    expanded_structure = structure.map { |s| Song.structure_interpreter(s) }
    
    return expanded_structure.map do |sec|
      
      section = sections.all.select { |s| s.type == sec[:type] }.find { |s| s.variation == sec[:variation] }
      
      raise "There is no section #{sec[:type]} with variation #{sec[:variation]} in this song." unless section
      
      section_tag = sec[:render_section_number] ? " #{sec[:lyric_variation]}" : ""
      title = "#{section.title}#{section_tag}"
      
      section_lines = Array.new
      
      sec[:repeat].times do |n|
        section_lines += section.render_lines( :variation  => sec[:lyric_variation], :modulation => sec[:modulation] )
      end
      
      next { :title => title, :lines => section_lines }
      
    end
    
  end
  
  # Counts the nnumber of variations of sections of the given type.  If no type given, counts all
  # variations of all sections.
  #
  # @param [String] type
  #   The type to check.
  # @return [Integer]
  #   The number of variations of sections of the given type.  If no type given, the number of all 
  #   variations of all sections.
  #
  def count_sections(type = nil)
    if type
      sections.all.select { |section| section.type == type }.size
    else
      sections.size
    end
  end
  
end