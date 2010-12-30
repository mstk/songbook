# Packet of information that can be assembled into a Song object.
#
class SongPacket
  
  attr_accessor :title, :artist, :time_signature
  
  @structure = Array.new
  @sections = Array.new
  @lyrics = Array.new
  
  def initialize(title,artist='',time_signature='')
    @title = title
    @artist = artist
    @time_signature = time_signature
    
    @edited = true
  end
  
  def build
    return @song if @song && !@edited
    
    @song.delete if @song
    
    @song = Song.create( :title => 'Blessed Be Your Name', :song_key => SongKey.KEY( :Bb ), :structure => structure )
    
    @sections.each do |section_data|
      
      section = section.build { :type         => section_data[:type],
                                :progressions => section_data[:progressions],
                                :song         => @song                        }
    end
    
    @edited = false
    
    @song
  end
  
  def add_section(type,progression_chords)
    @sections << { :type => type, :progressions => progression_chords }
    
    @edited = true
  end
  
  def add_lyric(lyric,section_type,lyric_variation=1,section_variation=1)
    @lyrics << {  :section_type       => section_type,
                  :lyric_variation    => lyric_variation,
                  :section_variation  => section_variation,
                  :lyric              => lyric              }
    
    @edited = true
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
  
end