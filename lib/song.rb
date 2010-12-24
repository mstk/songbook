class Song
  
  def count_sections(type = nil)
    if type
      sections.all.select { |section| section.type == type }.size
    else
      sections.size
    end
  end
  
end