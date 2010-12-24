require "#{File.dirname(__FILE__)}/spec_helper"

describe 'section' do
  
  before(:each) do
    @hiok = Song.create( :title => 'Here is Our King', :song_key => SongKey.KEY( :G ) )
    
    prog_1 = ChordProgression.first_or_create(:progression => [:I,:I_3,:IV,:IV])
    prog_2 = ChordProgression.first_or_create(:progression => [:vi,:V_3,:I,:I])
    prog_3 = ChordProgression.first_or_create(:progression => [:'ii-7',:I_3,:IV,:IV])
    
    @hiok_chorus = Section.create( :type => "CHORUS", :prog_order => [prog_1.id,prog_1.id], :song => @hiok)
    @hiok_bridge = Section.create( :type => "BRIDGE", :prog_order => [prog_2.id,prog_3.id], :song => @hiok)
    
    @hiok_chorus.chord_progressions << prog_1
    @hiok_bridge.chord_progressions << prog_2
    @hiok_bridge.chord_progressions << prog_3
    
    chorus_lyric_text = "Here is our\nKing, here is our\nLove, here is our\nGod who's come to\nbring us back to him\n\n"
    chorus_lyric_text += " \nHe is the one\nHe is Je-\nsus"
    bridge_lyric_text = " \nMa-\njes-\nty\n\n \nFi-\nna-\nly"
    bridge_lyric_text_2 = " \nMa-\njes-\nty\n\n \nFi-\nna-\nly\nhere"
    
    @chorus_lyric   = Lyric.parse( chorus_lyric_text, @hiok_chorus,0)
    @bridge_lyric   = Lyric.parse( bridge_lyric_text, @hiok_bridge,0)
    @bridge_lyric_2 = Lyric.parse( bridge_lyric_text_2, @hiok_bridge,1)
    
    @hiok_chorus.lyrics << @chorus_lyric
    @hiok_bridge.lyrics << @bridge_lyric
    @hiok_bridge.lyrics << @bridge_lyric_2
    
    @hiok_chorus.save
    @hiok_bridge.save
    
  end
  
  specify 'chorus chords should render properly in the song' do
    chord_progs = @hiok_chorus.render_chords
    chord_progs.size.should == 2
    
    chord_progs[0].should == [ :G, :'G/B', :C , :C ]
    chord_progs[1].should == [ :G, :'G/B', :C , :C ]
  end
  
  specify 'bridge chords should render properly modulated upwards 2' do
    chord_progs = @hiok_bridge.render_chords(2)
    chord_progs.size.should == 2
    
    chord_progs[0].should == [ :'F#m', :'E/G#', :A , :A ]
    chord_progs[1].should == [ :'Bm7', :'A/C#', :D , :D ]
  end
  
  specify 'chorus chords with lyrics should render properly modulated downards 2' do
    lines = @hiok_chorus.render_lines(:modulation => -2)
    lines.size.should == 2
    
    lines[0][:chords].should == [ :F, :'F/A', :Bb , :Bb ]
    lines[0][:lyrics].should == ["Here is our","King, here is our","Love, here is our","God who's come to","bring us back to him"]
    lines[1][:chords].should == [ :F, :'F/A', :Bb , :Bb ]
    lines[1][:lyrics].should == [" ","He is the one","He is Je-","sus"," "]
  end
  
  specify 'bridge chords with lyrics should render properly modulated up 4, second variation, as an iterator' do
    
    result_lines = [ { :chords => [ :'G#m', :'F#/A#', :B , :B ], :lyrics => [' ','Ma-','jes-','ty',' '] },
                     { :chords => [ :'C#m7', :'B/D#', :E , :E ], :lyrics => [' ','Fi-','na-','ly','here'] } ]
    
    i = 0
    @hiok_bridge.each_rendered_line(:modulation => 4, :variation => 1) do |line|
      line[:chords].should == result_lines[i][:chords]
      line[:lyrics].should == result_lines[i][:lyrics]
      i += 1
    end
  end
  
  specify 'chorus chords with lyrics should render properly modulated downwards 3, with an unknown variation' do
    lines = @hiok_chorus.render_lines(:modulation => -3, :variation => 1)
    lines.size.should == 2
    
    lines[0][:chords].should == [ :E, :'E/G#', :A , :A ]
    lines[0][:lyrics].should == [' ',' ',' ',' ',' ']
    lines[1][:chords].should == [ :E, :'E/G#', :A , :A ]
    lines[1][:lyrics].should == [' ',' ',' ',' ',' ']
  end
  
end