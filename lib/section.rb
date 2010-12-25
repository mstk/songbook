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
  # @option options [Boolean] :render_repeats (false)
  #   Whether or not to render the chord if it is a repeat of the last, replacing it with a blank
  #   symbol.
  # @return [Array<Hash{Symbol,Array<Symbol,String>}>]
  #   An array with a hash for each line.
  #   
  #   Each hash has two key/value pairs -- `:chords`, for the absolute chords of the line in an 
  #   array, and `:lyrics`, for the lyrics for the line split up at each chord change, in an array.
  # 
  def render_lines(options)
    modulation = options[:modulation] || 0
    lyric_variation = options[:variation] || 1
    render_repeats = options[:render_repeats] || false
    
    chords = render_chords(modulation,render_repeats)
    
    lyric = lyrics.all.find { |l| l.variation == lyric_variation }
    
    lyric_lines = lyric ? lyric.render_lines : line_lengths.map { |l| Array.new(l+1) {' '} }
    
    (0..chords.length-1).map { |n| { :chords => [:''] + chords[n], :lyrics => lyric_lines[n] } }
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
  
end