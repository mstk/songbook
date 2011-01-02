require "#{File.dirname(__FILE__)}/spec_helper"

describe 'section' do
  
  before(:each) do
    @hiok = Song.create( :title => 'Here is Our King', :song_key => SongKey.KEY( :G ) )
    
    prog_1 = ChordProgression.first_or_create(:progression => [:I,:I_3,:IV,:IV])
    prog_2 = ChordProgression.first_or_create(:progression => [:vi,:V_3,:I,:I])
    prog_3 = ChordProgression.first_or_create(:progression => [:'ii-7',:I_3,:IV,:IV])
    
    @hiok_chorus = Section.build( :type => "CHORUS", :progressions => [prog_1,prog_1], :song => @hiok)
    @hiok_bridge = Section.build( :type => "BRIDGE", :progressions => [prog_2,prog_3], :song => @hiok)
    
    chorus_lyric_text = "Here is our\nKing, here is our\nLove, here is our\nGod who's come to\nbring us back to him\n\n"
    chorus_lyric_text += " \nHe is the one\nHe is Je-\nsus"
    bridge_lyric_text = " \nMa-\njes-\nty\n\n \nFi-\nna-\nly"
    bridge_lyric_text_2 = " \nMa-\njes-\nty\n\n \nFi-\nna-\nly\nhere"
    
    Lyric.build( chorus_lyric_text, @hiok_chorus,1)
    Lyric.build( bridge_lyric_text, @hiok_bridge,1)
    Lyric.build( bridge_lyric_text_2, @hiok_bridge,2)
    
  end
  
  specify 'chorus chords should render properly in the song with rendered repeats' do
    chord_progs = @hiok_chorus.render_chords(0,true)
    chord_progs.size.should == 2
    
    chord_progs[0].should == [ :G, :'G/B', :C , :C ]
    chord_progs[1].should == [ :G, :'G/B', :C , :C ]
  end
  
  specify 'bridge chords should render properly modulated upwards 2' do
    chord_progs = @hiok_bridge.render_chords(2)
    chord_progs.size.should == 2
    
    chord_progs[0].should == [ :'F#m', :'E/G#', :A , :'' ]
    chord_progs[1].should == [ :'Bm7', :'A/C#', :D , :'' ]
  end
  
  specify 'chorus chords with lyrics should render properly modulated downards 2' do
    lines = @hiok_chorus.render_lines(:modulation => -2)
    lines.size.should == 2
    
    lines[0][:chords].should == [ :'', :F, :'F/A', :Bb]
    lines[0][:lyrics].should == ["Here is our ","King, here is our ","Love, here is our ","God who's come to bring us back to him"]
    lines[1][:chords].should == [ :F, :'F/A', :Bb]
    lines[1][:lyrics].should == [ "He is the one ","He is Je-","sus" ]
  end
  
  specify 'bridge chords with lyrics should render properly modulated up 4, second variation, as an iterator' do
    
    result_lines = [ { :chords => [ :'G#m', :'F#/A#', :B ], :lyrics => ['Ma-','jes-','ty'] },
                     { :chords => [ :'C#m7', :'B/D#', :E ], :lyrics => ['Fi-','na-','ly here'] } ]
    
    i = 0
    @hiok_bridge.each_rendered_line(:modulation => 4, :variation => 2) do |line|
      line[:chords].should == result_lines[i][:chords]
      line[:lyrics].should == result_lines[i][:lyrics]
      i += 1
    end
  end
  
  specify 'chorus chords with lyrics should render properly modulated downwards 3, with an unknown variation' do
    lines = @hiok_chorus.render_lines(:modulation => -3, :variation => 2)
    lines.size.should == 1
    
    lines[0][:chords].should == [ :E, :'E/G#', :A ]
    lines[0][:repeat].should == 2
  end
  
  specify 'should render title properly' do
    @hiok_chorus.title.should == "CHORUS"
  end
  
  specify 'should render chords summary properly' do
    chords_summary = @hiok_chorus.render_progression_summary
    chords_summary.size.should == 1
    
    chords_summary[0][:chords].should == [:G,:'G/B',:C]
    chords_summary[0][:repeat].should == 2
    
  end
  
end