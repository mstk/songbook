# Packet of information that can be assembled into a Song object.
#
class SongPacket
  
  attr_reader :title, :song_key, :artist, :time_signature
  
  @structure = Array.new
  @sections = Array.new
  @lyrics = Array.new
  
  def initialize(title,song_key,artist='',time_signature='')
    @title = title
    @song_key = song_key
    @artist = artist
    @time_signature = time_signature
    
    @edited = true
  end
  
  def build!
    build(true)
  end
  
  def build(force = false)
    
    return @song if @song && !@edited
    
    raise "Already built" if force && @song
    
    @song.delete if @song
    
    @song = Song.create(  :title => @title,
                          :song_key => SongKey.KEY( :Bb ),
                          :artist   => @artist,
                          :time_signature => @time_signature,
                          :structure => @structure )
    
    @sections.each do |section_data|
      
      progression_array = section_data[:progresssions].map do |progression|
        # make less naive
        ChordProgression.first_or_create(:progression => [progression] )
      end
      
      section = section.build { :type         => section_data[:type],
                                :progressions => progression_array,
                                :variation    => section_data[:variation],
                                :song         => @song                    }
      
      
      added_lyric_variations = Array.new
      
      @lyrics.select { |l| l[:section_type] == section_data[:type] && l[:section_variation] == section_data[:variation] }.each do |lyric|
        next if added_lyric_variations.include? lyric[:lyric_variation]
        
        Lyric.build( l[:lyric], section, lyric[:lyric_variation] )
        
        added_lyric_variations << lyric[:lyric_variation]
      end
    end
    
    @edited = false
    
    @song
  end
  
  def add_section(type,progression_chords,varation=1)
    
    @sections << { :type => type, :progressions => progression_chords, :variation => variation }
    
    @edited = true
  end
  
  def add_lyric(lyric,section_type,lyric_variation=1,section_variation=1)
    @lyrics << {  :section_type       => section_type,
                  :lyric_variation    => lyric_variation,
                  :section_variation  => section_variation,
                  :lyric              => lyric              }
    
    @edited = true
  end
  
  def remove_lyric(section_type,lyric_variation=1,section_variation=1)
    @lyrics.reject! { |l| l[:section_type] == section_type && l[:lyric_variation] == lyric_variation && l[:section_variation] = section_variation }
  end
  
  def set_structure(structure)
    @structure = structure
    @edited = true
  end
  
  # @see Song#structure_interpreter for details on params
  #
  def add_structure(params)
    raise ArgumentError unless params[:type]
    
    @structure << params
    @edited = true
  end
  
  def clear_structure
    @structure = Array.new
    @edited = true
  end
  
  def structure
    @structure.map { |s| s.clone }
  end
  
  #####
  
  # make these cleaner
  
  def title=(new_title)
    @title = new_title
    @edited = true
  end
  
  def song_key=(new_key)
    @song_key = new_key
    @edited = true
  end
  
  def artist=(new_artist)
    @artist = new_artist
    @edited = true
  end
  
  def time_signature=(new_signature)
    @time_signature = new_signature
    @edited = true
  end
  
end