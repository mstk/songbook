# Represents a section of the song.  Contains a type (chorus, verse, etc.) and a sequence of chord
# progressions that make up the section.  In charge of rendering the progressions into the 
# appropriate key, as given by the song it is in and the modulation of the call.  Sections are 
# never shared across songs.  Lyrics are also managed here.
#
# It can be possible to have two completely different chorus or verse sections by having different
# `variation` properties.  Please do not set a type as "CHORUS_2".
# 
# @author Justin Le
# 
class Section
  
  # Builds and saves section given `:progressions`, a list of progressions, and `:song`, the song 
  # the section is in.
  # 
  # @param [Hash] properties
  #   The properties of the Section to build.
  # @option properties [Song] :song
  #   The required song that the section is a part of.
  # @option properties [Array<ChordProgression>] :progressions
  #   Required list of chord progressions that make up the song, in order, by line.
  # @option properties [String] :type ('CHORUS')
  #   The type of section.
  # @option properties [Integer] :variation (1)
  #   If multiple sections of the same type in one song, use this to differentiate them.
  # @return [Section]
  #   The built section.
  #
  def Section.build(properties)
    properties[:type] ||= "CHORUS"
    properties[:variation] ||= 1
    
    raise ArgumentError unless properties[:progressions]
    raise ARgumentError unless properties[:song]
    
    prog_order = properties[:progressions].map { |prog| prog.id }
    
    section = Section.create( :type => properties[:type],
                              :song => properties[:song],
                              :variation => properties[:variation],
                              :prog_order => prog_order )
    
    properties[:progressions].each do |prog|
      section.chord_progressions << prog
      prog.save
    end
    
    section.save
    section
  end
  
  # Renders every chord progression in the section into the key of the song (or a modulation of it)
  # and returns them as an array of lines of absolute chords.
  #
  # @param [Integer] modulation
  #   An optional modulation parameter to modulate the song's key for this rendering particular 
  #   section.
  # @param [Boolean] render_repeats
  #   Whether or not to render the chord if it is a repeat of the last, replacing it with a blank
  #   symbol.
  # @return [Array<Array<Symbol>>]
  #   An array of lines (arrays) of absolute chords, in symbols.
  # 
  def render_chords(modulation = 0,render_repeats = false)
    progressions = prog_order.map { |prog_id| ChordProgression.get(prog_id) }
    rendered_chords = progressions.map { |prog| prog.render_into ( @song.song_key.transpose(modulation) ) }
    
    unless render_repeats
      rendered_chords.each do |line|
        curr_chord = nil
        line.length.times do |n|
          if line[n] == curr_chord
            line[n] = :''
          else
            curr_chord = line[n]
          end
        end
      end
    end
    
    rendered_chords
  end
  
  # Renders every chord progression in the section into the key of the song (or a modulation of it)
  # and also extracts all of the lines from the lyrical block attached to the given variation, and
  # pairs them up and returns those pairs as hashes in an array of lines.
  #
  # @param [Hash] options
  #   Options for rendering the lines.
  # @option options [Integer] :modulation (0)
  #   Optional modulation parameter to modulate the song's key for rendering this particular 
  #   section.
  # @option options [Integer] :variation (1)
  #   Variation of the lyrics for the section to use.  Defaults to 1.  If the variation is not
  #   found, will return blank strings for lyrical lines.
  # @option options [Boolean] :render_full (false)
  #   Whether or not to render the chord if it is a repeat of the last, replacing it with a blank
  #   symbol.
  # @option options [Boolnea] :force_lyrics (false)
  #   Disallows Section to automatically switch to Instrumental summary output if there are no
  #   lyrics present.
  # @return [Array<Hash{Symbol,Array<Symbol,String>}>]
  #   An array with a hash for each line.
  #   
  #   Each hash has two key/value pairs -- `:chords`, for the absolute chords of the line in an 
  #   array, and `:lyrics`, for the lyrics for the line split up at each chord change, in an array.
  # 
  def render_lines(options)
    modulation = options[:modulation] || 0
    lyric_variation = options[:variation] || 1
    render_full = options[:full] || false
    force_lyrics = options[:force_lyrics] || false
    
    lyric = lyrics.all.find { |l| l.variation == lyric_variation }
    
    if force_lyrics or (lyric && !lyric.is_empty?)
    
      chords = render_chords(modulation,render_full)
    
      lyric_lines = lyric.render_lines
      
      if render_full
        return (0..chords.length-1).map { |n| { :chords => [:''] + chords[n], :lyrics => lyric_lines[n], :instrumental => false, :repeat => 1 } }
      else
        return (0..chords.length-1).map do |n|
          
          has_pickup = lyric_lines[n][0].length > 0 && lyric_lines[n][0] != ' '
          
          full_lyrics = Array.new
          
          full_lyrics << lyric_lines[n][0] if has_pickup
          
          chords[n].length.times do |i|
            
            curr_line = lyric_lines[n][i+1]
            
            if chords[n][i] == :''
              full_lyrics[-1] = full_lyrics[-1][0..-2] if full_lyrics[-1][-1] == '-'
              full_lyrics[-1] += curr_line unless curr_line == ' '
            else
              full_lyrics << curr_line
            end
          end
          
          stripped_chords = chords[n].reject { |c| c == :'' }
          
          stripped_chords.unshift(:'') if has_pickup
          
          next { :chords => stripped_chords, :lyrics => full_lyrics, :instrumental => false, :repeat => 1 }
          
        end
      end
    else
      return render_chords_summary(modulation,render_full)
    end
  end
  
  # Iterates through the lines in this section.
  #
  # @param [Hash] options
  #   Options for rendering the lines.
  # @option options [Integer] :modulation (0)
  #   Optional modulation parameter to modulate the song's key for rendering this particular 
  #   section.
  # @option options [Integer] :variation (1)
  #   Variation of the lyrics for the section to use.  Defaults to 1.  If the variation is not
  #   found, will return blank strings for lyrical lines.
  # @option options [Boolean] :render_repeats (false)
  #   Whether or not to render the chord if it is a repeat of the last, replacing it with a blank
  #   symbol.
  # @return [Hash{Symbol,Array<Symbol,String>}]
  #   A hash representing the line, with two key/value pairs -- `:chords`, for the absolute chords 
  #   of the line in an array, and `:lyrics`, for the lyrics for the line split up at each chord 
  #   change, in an array.
  # 
  def each_rendered_line(options)
    render_lines(options).each { |l| yield l }
  end
  
  def render_chords_summary(modulation = 0,render_repeats = false)
    rendered_chords = render_chords(modulation,render_repeats)
    
    chords_summary = Array.new
    
    curr_progression = rendered_chords[0]
    curr_repeat = 0
    
    (rendered_chords + [nil]).each do |progression|
      if progression == curr_progression
        curr_repeat += 1
      else
        
        stripped_progression = curr_progression.reject { |c| c == :'' }
        
        chords_summary << {:chords => stripped_progression, :repeat => curr_repeat, :instrumental => true, :lyrics => [' '] * curr_progression.length }
        
        curr_progression = progression
        curr_repeat = 1
      end
    end
    
    chords_summary
  end
  
  # The number of lines/chord progressions in this section.
  #
  # @return [Integer]
  #   The number of lines in this section.
  #
  def line_count
    prog_order.length
  end
  
  # An array containing the lengths, in bars/chord changes, of each line in this section.
  #
  # @return [Array<Integer>]
  #   Array of lengths of each line/chord progression, in bars/chord changes.
  # 
  def line_lengths
    prog_order.map { |prog_id| ChordProgression.get(prog_id) }.map { |p| p.length }
  end
  
  # The title of the section.  This will usually just be the type.  However, if there are more than
  # one variations of the section within the song, it will be be appanded with a letter 
  # representing its variation.
  #
  # @return [String]
  #   The title of the section
  #
  def title
    if song.count_sections(type) <= 1
      type
    else
      "#{type} #{(variation + 9).to_s(36).upcase}"
    end
  end
  
  def delete
    lyrics.each { |lyric| lyric.delete }
    super
  end
  
end