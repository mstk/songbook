# Packet of information that can be assembled into a Song object.  Used for building up information
# piece-by-piece, and handles most of the boilerplate safely.
#
# @author Justin Le
#
class SongPacket
  
  attr_reader :title, :song_key, :artist, :time_signature, :comments
  
  # Starts off a new Song Packet, with a title, song_key, artist, and time signature.  Title is
  # required.
  # 
  # @param [Hash] params
  #   Options for rendering the lines.
  # @option params [String] :title
  #   The title of the song.
  # @option params [String] :song_key (C)
  #   A text representation of the key of the song.
  # @option params [String] :artist ('')
  #   The artist of the song.  Defaults to a blank string.
  # @option params [String] :time_signature ('4/4')
  #   Text representation of the time signature of the song.
  # 
  def initialize(params={})
    
    raise ArgumentError unless params[:title]
    @title = params[:title]
    
    @song_key = params[:song_key] || 'C'
    @artist = params[:artist] || ''
    @time_signature = params[:time_signature] || '4/4'
    @comments = params[:comments] || ''
    @tags = params[:tags] || []
    
    @edited = true
    
    @structure = Array.new
    @sections = Array.new
    @lyrics = Array.new
  end
  
  # Builds the Song describe the packet and returns it.  Will automatically erase the old song if
  # this packet was previously built.
  #
  # @return [Song]
  #   The song described in the packet.
  #
  def build!
    build(true)
  end
  
  # Builds the Song describe the packet and returns it.
  #
  # @param [Boolean] force
  #   Whether or not to force the song to be re-built if the packet has already been built.  If 
  #   false, will raise an error in that case.
  # @return [Song]
  #   The song described in the packet.
  # @raise
  #   Will raise `Already Built` if the packet has already been built from, unless `force` is true.
  #
  def build(force = false)
    
    return @song if @song && !@edited
    
    raise "Already built" if force && @song
    
    
    ## lol wtf...have some way to edit the previous song?
    @song.delete if @song
    
    @song = Song.create(  :title => @title,
                          :song_key => SongKey.KEY( @song_key ),
                          :artist   => @artist,
                          :time_signature => @time_signature,
                          :structure => @structure,
                          :comments => @comments )
    
    @sections.each do |section_data|
      
      progression_array = section_data[:progressions].map do |progression|
        # make less naive
        
        progression_symbols = progression.map do |chord|
          chord_string = chord.to_s
          if ['I','V','i','v','b'].include? chord[0]
            next chord.intern
          else
            next Chord.RELATIVE(chord.intern,@song.song_key).symbol
          end
        end
        
        ChordProgression.first_or_create(:progression => progression_symbols )
      end
      
      section = Section.build(:type         => section_data[:type],
                              :progressions => progression_array,
                              :variation    => section_data[:variation],
                              :song         => @song                    )
      
      
      added_lyric_variations = Array.new
      
      @lyrics.select { |l| l[:section_type] == section_data[:type] && l[:section_variation] == section_data[:variation] }.each do |lyric|
        next if added_lyric_variations.include? lyric[:lyric_variation]
        
        Lyric.build( lyric[:lyric], section, lyric[:lyric_variation], lyric[:includes_invisible] )
        
        added_lyric_variations << lyric[:lyric_variation]
      end
    end
    
    @tags.each do |tag|
      @song.tags.first_or_create(:text => tag)
    end
    
    @edited = false
    
    @song
  end
  
  # Add a new section to the song's structure.
  # 
  # @param [String] type
  #   The section type (`'VERSE'`, `'CHORUS'`, etc.)
  # @param [Array<Array<String,Symbol>>] progression_chords
  #   An array of lines of chords, in either relative or absolute terms.
  # @param [Integer] variation
  #   The variation of the section type in the song (ie, 1st chorus or 2nd chorus)
  #
  def add_section(type,progression_chords,variation=1)
    @sections << { :type => type, :progressions => progression_chords, :variation => variation }
    
    @edited = true
  end
  
  # Attaches a lyric to the given section
  # 
  # @param [String] lyric
  #   The lyrical text block.  See Lyric for more information on formatting.  Basically delimited
  #   by two newlines per line of the song and one newline per chord change.  Must include a
  #   "pickup" string for each line for words before the first chord of a line.
  # @param [String] section_type
  #   The type of the section the lyric is attached to (`'VERSE'`, `'CHORUS'`, etc.).
  # @param [Integer] lyric_variation
  #   The variation of lyric for this section.  For example, the first verse or the second verse.
  # @param [Integer] section_variation
  #   The variation of the section that this lyric is attached to.
  # @param [Boolean] includes_invisible
  #   Whether or not the given text lyric block includes "invisible" chord changes, or chord 
  #   changes that change to the same chord.
  #
  def add_lyric(lyric,section_type,lyric_variation=1,section_variation=1,includes_invisible=false)
    @lyrics << {  :section_type       => section_type,
                  :lyric_variation    => lyric_variation,
                  :section_variation  => section_variation,
                  :includes_invisible => includes_invisible,
                  :lyric              => lyric              }
    
    @edited = true
  end
  
  # Removes the given lyric from the given section.
  #
  # @param [String] section_type
  #   The section type (`'VERSE'`, `'CHORUS'`, etc.)
  # @param [Integer] lyric_variation
  #   The lyric variation of the section to remove.
  # @param [Integer] section_variation
  #   The variation of the section the lyric is attached to.
  #
  def remove_lyric(section_type,lyric_variation=1,section_variation=1)
    @lyrics.reject! { |l| l[:section_type] == section_type && l[:lyric_variation] == lyric_variation && l[:section_variation] = section_variation }
  end
  
  # Replaces the current song structure in this packet with a new one.
  # 
  # @param [Array] structure
  #   Valid song structure.
  # 
  # @see Song
  #
  def set_structure(structure)
    @structure = structure.map { |s| s.clone }
    @edited = true
  end
  
  # Adds a new section to the song structure.
  # 
  # @param [Hash] params
  #   New section with parameters.
  #   See `Song#structure_interpreter` for details on parameters
  # 
  def add_structure(params)
    raise ArgumentError unless params[:type]
    
    @structure << params
    @edited = true
  end
  
  # Clears the current stored structure.
  # 
  def clear_structure
    @structure = Array.new
    @edited = true
  end
  
  # Changes the value for the given field to the new value.
  # 
  # @param [Symbol] field
  #   `:title`, `:song_key`, `:artist`, `:time_signature`, or `:comments`.
  # @param [String] new_value
  #   New value for the given field
  # 
  def change(field,new_value)
    case field
    when :title
      @title = new_value
    when :song_key
      @song_key = new_value
    when :artist
      @artist = new_value
    when :time_signature
      @time_signature = new_value
    when :comments
      @comments = new_value
    else
      raise ArgumentError
    end
    
    @edited = true
  end
  
  # Adds a new tags to the tag list.
  # 
  # @param [String]
  #   The new tag to add.
  # 
  def add_tag(new_tag)
    @tags << new_tag
  end
  
  # Deletes a new tags to the tag list.
  # 
  # @param [String]
  #   The tag to delete.
  # 
  def delete_tag(to_delete)
    @tags.delete(to_delete)
  end
  
  # Clears the current stored tags.
  # 
  def clear_tags
    @tags = []
  end
  
end