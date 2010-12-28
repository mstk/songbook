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
  def render_sections(options = {})
    
    # find render key
    render_key = song_key
    render_key = song_key.transpose(options[:modulation]) if options[:modulation]
    if options[:alt_key]
      if options[:alt_key].class == SongKey
        render_key = options[:alt_key]
      else
        render_key = SongKey.KEY( options[:alt_key] )
      end
    end
    
    # should be rendered fully?
    render_full = options[:full] || false
    
    # should all sections be rendered
    render_all_sections = options[:render_all_sections] || false
    
    # should lyrics be forced?
    force_lyrics = options[:force_Lyrics] || false
    
    expanded_structure = structure.map { |s| Song.structure_interpreter(s) }
    
    sections_so_far = Hash.new
    
    return expanded_structure.map do |sec|
      
      section_fingerprint = { :type => sec[:type],
                              :variation => sec[:variation],
                              :modulation => sec[:modulation],
                              :lyric_variation => sec[:lyric_variation] }
                              
      if render_all_sections || !sections_so_far.keys.include?(section_fingerprint)
        
        section = sections.all.select { |s| s.type == sec[:type] }.find { |s| s.variation == sec[:variation] }
        
        raise "There is no section #{sec[:type]} with variation #{sec[:variation]} in this song." unless section
        
        section_tag = sec[:render_section_number] ? " #{sec[:lyric_variation]}" : ""
        title = "#{section.title}#{section_tag}"
        
        section_lines = Array.new
        
        section_lines += section.render_lines(  :variation  => sec[:lyric_variation],
                                                :modulation => sec[:modulation],
                                                :full => render_full,
                                                :force_lyrics => force_lyrics )
        
        section_data = { :title => title,
                         :lines => section_lines,
                         :instrumental => section_lines[-1][:instrumental],
                         :repeats => sec[:repeat],
                         :is_repeat => false }
        
        sections_so_far[section_fingerprint] = section_data
        
        next section_data
        
      else
        
        prev_repeat = sections_so_far[section_fingerprint]
        
        next { :title => prev_repeat[:title],
               :instrumental => prev_repeat[:instrumental],
               :repeats => sec[:repeat],
               :is_repeat => true }
        
      end
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