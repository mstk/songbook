class Song
  
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
    
    expanded_structure = interpret_structure
    
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
  
  def interpret_structure
    @structure.map { |s| Song.structure_interpreter(s) }
  end
  
  def count_sections(type = nil)
    if type
      sections.all.select { |section| section.type == type }.size
    else
      sections.size
    end
  end
  
end