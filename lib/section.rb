# Represents a section of the song.  Contains a type (chorus, verse, etc.) and a sequence of chord
# progressions that make up the section.  In charge of rendering the progressions into the 
# appropriate key, as given by the song it is in and the modulation of the call.  Sections are 
# never shared across songs.  Lyrics are also managed here.
# 
# @author Justin Le
# 
class Section
  
  def render_chords(modulation = 0)
    progressions = @prog_order.map { |prog_id| ChordProgression.get(prog_id) }
    progressions.map { |prog| prog.render_into ( @song.song_key.transpose(modulation) ) }
  end
  
  def render_lines(params)
    modulation = params[:modulation] || 0
    lyric_variation = params[:variation] || 0
    
    chords = render_chords(modulation)
    
    lyric = lyrics.all.find { |l| l.variation == lyric_variation }.render_lines
    
    (0..chords.length-1).map { |n| { :chords => chords[n], :lyrics => lyric[n] } }
  end
  
  def line_count
    chord_progressions.length
  end
  
  def line_lengths
    @prog_order.map { |prog_id| ChordProgression.get(prog_id) }.map { |p| p.length }
  end
  
end