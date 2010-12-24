# Represents a section of the song.  Contains a type (chorus, verse, etc.) and a sequence of chord
# progressions that make up the section.  In charge of rendering the progressions into the 
# appropriate key, as given by the song it is in and the modulation of the call.  Sections are 
# never shared across songs.  Lyrics are also managed here.
# 
# @author Justin Le
# 
class Section
  
  def Section.build(properties)
    properties[:type] ||= "CHORUS"
    properties[:variation] ||= 0
    
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
  
  
    property :type,       String, :default => "CHORUS"
  property :variation,  Integer, :default => 0
  property :prog_order, Yaml, :lazy => true
  
  # will be covered by @order in Song
  # property :lyric_order,Yaml, :lazy => true, :default => [0]
  
  belongs_to :song
  
  
  # Renders every chord progression in the section into the key of the song (or a modulation of it)
  # and returns them as an array of lines of absolute chords.
  #
  # @param [Integer] modulation
  #   An optional modulation parameter to modulate the song's key for this rendering particular 
  #   section.
  # @return [Array<Array<Symbol>>]
  #   An array of lines (arrays) of absolute chords, in symbols.
  # 
  def render_chords(modulation = 0)
    progressions = @prog_order.map { |prog_id| ChordProgression.get(prog_id) }
    progressions.map { |prog| prog.render_into ( @song.song_key.transpose(modulation) ) }
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
  # @option options [Integer] :variation (0)
  #   Variation of the lyrics for the section to use.  Defaults to 0.  If the variation is not
  #   found, will return blank strings for lyrical lines.
  # @return [Array<Hash{Symbol,Array<Symbol,String>}>]
  #   An array with a hash for each line.
  #   
  #   Each hash has two key/value pairs -- `:chords`, for the absolute chords of the line in an 
  #   array, and `:lyrics`, for the lyrics for the line split up at each chord change, in an array.
  # 
  def render_lines(options)
    modulation = options[:modulation] || 0
    lyric_variation = options[:variation] || 0
    
    chords = render_chords(modulation)
    
    lyric = lyrics.all.find { |l| l.variation == lyric_variation }
    
    lyric_lines = lyric ? lyric.render_lines : line_lengths.map { |l| Array.new(l+1) {' '} }
    
    (0..chords.length-1).map { |n| { :chords => chords[n], :lyrics => lyric_lines[n] } }
  end
  
  # Iterates through the lines in this section.
  #
  # @param [Hash] options
  #   Options for rendering the lines.
  # @option options [Integer] :modulation (0)
  #   Optional modulation parameter to modulate the song's key for rendering this particular 
  #   section.
  # @option options [Integer] :variation (0)
  #   Variation of the lyrics for the section to use.  Defaults to 0.  If the variation is not
  #   found, will return blank strings for lyrical lines.
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
    @prog_order.length
  end
  
  # An array containing the lengths, in bars/chord changes, of each line in this section.
  #
  # @return [Array<Integer>]
  #   Array of lengths of each line/chord progression, in bars/chord changes.
  # 
  def line_lengths
    @prog_order.map { |prog_id| ChordProgression.get(prog_id) }.map { |p| p.length }
  end
  
end