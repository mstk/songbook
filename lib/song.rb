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
    repeat                = params[:repeat] || 1
    
    { :type                   => type,
      :variation              => variation,
      :modulation             => modulation,
      :lyric_variation        => lyric_variation,
      :repeat                 => repeat }
  end
  
  # Returns a hash of the basic information for the song.
  # 
  # @return [Hash{Symbol => String, Array<String>}]
  #   A hash containing the basic information for the song, including:
  #   
  #     - `:title`, the title of the song
  #     - `:artist`, the artist of the song
  #     - `:key`, the key of the song, as a string
  #     - `:time_signature`, the time signature of the song, as a string
  #     - `:comments`, the comments on the song
  #     - `:tags`, the tags attached to the song, as an array of strings
  #
  #
  def info
    
    return  { :title          => title,
              :artist         => artist,
              :key            => song_key.symbol.to_s,
              :time_signature => time_signature,
              :comments       => comments,
              :tags           => tags.map { |t| t.text } }
    
  end
  
  # Returns a hash of the song's data, including info and rendered sections.
  #
  # @param [Array<Symbol>] to_render
  #   What the output hash should include.  Options are:
  #     - `:info`
  #     - `:sections`
  #     - `:structure`
  #
  #
  def render_data(to_render = [:info,:sections,:structure])
    
    out = {}
    
    if to_render.include? :info
      out[:info] = info
    end
    
    if to_render.include? :sections
      out[:sections] = sections.all.map do |section|
        section_data =  { :title  => section.title }
        
        num_vars = section.lyric_variation_count
        num_vars = 1 if num_vars < 1
        
        rendered_lines = (0...num_vars).map { |v| section.render_lines( :variation  => v+1,
                                                                        :force_lyrics => true,  # make this work lol. eventually
                                                                        :full => true ) }
        
        
        
        # repeat_structures = section.repeat_structures
        
        
        section_data[:lines] = (0...section.line_count).map do |n|
          { :chords           => rendered_lines[0][n][:chords],
            # :repeat_structure => repeat_structures[n],
            :lyrics           => rendered_lines.map { |l| l[n][:lyrics] } }
        end
        
        next section_data
      end
    end
    
    if to_render.include? :structure
      loaded_structure = structure.empty? ? default_structure : structure
      expanded_structure = loaded_structure.map { |s| Song.structure_interpreter(s) }
      
      out[:structure] = expanded_structure
    end
    
    
    return out
    
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
    
    loaded_structure = structure.empty? ? default_structure : structure
    
    expanded_structure = loaded_structure.map { |s| Song.structure_interpreter(s) }
    
    sections_so_far = Hash.new
    
    return expanded_structure.map do |sec|
      
      section_fingerprint = { :type => sec[:type],
                              :variation => sec[:variation],
                              :modulation => sec[:modulation],
                              :lyric_variation => sec[:lyric_variation] }
                              
      if render_all_sections || !sections_so_far.keys.include?(section_fingerprint)
        
        section = sections.all.select { |s| s.type == sec[:type] }.find { |s| s.variation == sec[:variation] }
        
        raise "There is no section #{sec[:type]} with variation #{sec[:variation]} in this song." unless section
        
        render_section_number = section.lyrics.size > 1
        
        section_tag = render_section_number ? " #{sec[:lyric_variation]}" : ""
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
  
  # Counts the number of variations of sections of the given type.  If no type given, counts all
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
  
  # Deletes this Song resource from the database, as well as the associated Section resources.
  #
  def delete
    sections.each { |section| section.delete }
    super
  end
  
  private
  
  def default_structure
    
    intro = sections.any? { |section| section.type == 'INTRO' }
    preverse = sections.any? { |section| section.type == 'PREVERSE' && section.variation == 1 }
    verse = sections.any? { |section| section.type == 'VERSE' && section.variation == 1 }
    prechorus = sections.any? { |section| section.type == 'PRECHORUS' && section.variation == 1 }
    chorus = sections.any? { |section| section.type == 'CHORUS' && section.variation == 1 }
    postchorus = sections.any? { |section| section.type == 'POSTCHORUS' && section.variation == 1 }
    bridge = sections.any? { |section| section.type == 'BRIDGE' }
    outro = sections.any? { |section| section.type == 'OUTRO' }
    
    # those that don't fit
    others = sections.reject { |section| ['INTRO','SOLO','INSTRUMENTAL','BRIDGE','OUTRO'].include? section.type }
    others.reject! { |section| ['PREVERSE','VERSE','PRECHORUS','CHORUS','POSTCHORUS'].include?(section.type) && section.variation == 1 }
    
    out = Array.new
    
    special_structures = ['INTRO','SOLO','INSTRUMENTAL','BRIDGE','OUTRO'].map do |section_type|
      
      section_structure = Array.new
      
      matching_sections = sections.select { |section| section.type == section_type }
      
      matching_sections.each do |section_variation|
        var_count = section_variation.lyrics.size
        
        var_count = 1 if var_count == 0
        
        var_count.times do |n|
          section_structure << { :type => section_type, :variation => section_variation.variation, :lyric_variation => n+1 }
        end
      end
      
      next section_structure
    end
    
    # add intros
    special_structures[0].each { |intro| out << intro }
    
    if verse
      first_verse = sections.find { |section| section.type == 'VERSE' && section.variation == 1 }
      verse_count = first_verse.lyrics.size
      
      out << { :type => 'PREVERSE' } if preverse
      
      verse_count.times do |n|
        out << { :type => 'VERSE', :lyric_variation => n+1 }
        if n == 0
          out << { :type => 'PRECHORUS' } if prechorus
          out << { :type => 'CHORUS' } if chorus
          out << { :type => 'POSTCHORUS' } if postchorus
        end
      end
    else
      out << { :type => 'PRECHORUS' } if prechorus
      out << { :type => 'CHORUS' } if chorus
      out << { :type => 'POSTCHORUS' } if postchorus
    end
    
    # add solos, instrumentals, bridges, outros
    special_structures[1..-1].each { |s| s.each { |s_var| out << s_var } }
    
    # add others
    others.each do |other|
      var_count = other.lyrics.size
        
      var_count = 1 if var_count == 0
      
      var_count.times do |n|
        out << { :type => other.type, :variation => other.variation, :lyric_variation => n+1 }
      end
    end
    
    return out
    
  end
  
end