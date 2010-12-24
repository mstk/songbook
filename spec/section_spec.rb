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
    
    chorus_lyric_text = "Here is our King\nHere is our Love\nHere is our God whose come\nto bring us back to Him\n\n"
    chorus_lyric_text += "He is the one\nHe is Jesus"
    bridge_lyric_text = "Ma-\njes-\nty\n\nFi-\nna-\nly"
    bridge_lyric_text_2 = "Ma-\njes-\nty\n\nFi-\nna-\nly\nhere"
    
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
    lines[0][:lyrics].should == ['Here is our King','Here is our Love','Here is our God whose come','to bring us back to Him']
    lines[1][:chords].should == [ :F, :'F/A', :Bb , :Bb ]
    lines[1][:lyrics].should == ['He is the one','He is Jesus','','']
  end
  
  specify 'bridge chords with lyrics should render properly modulated up 4, second variation' do
    lines = @hiok_bridge.render_lines(:modulation => 4, :variation => 1)
    lines.size.should == 2
    
    lines[0][:chords].should == [ :'G#m', :'F#/A#', :B , :B ]
    lines[0][:lyrics].should == ['Ma-','jes-','ty','']
    lines[1][:chords].should == [ :'C#m7', :'B/D#', :E , :E ]
    lines[1][:lyrics].should == ['Fi-','na-','ly','here']
  end
  
end