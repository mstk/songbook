require "#{File.dirname(__FILE__)}/spec_helper"

describe 'lyric' do
  
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
  
  specify 'chorus lyrics should render properly' do
    lines = @chorus_lyric.render_lines
    lines.size.should == 2
    
    lines[0].should == ['Here is our King','Here is our Love','Here is our God whose come','to bring us back to Him']
    lines[1].should == ['He is the one','He is Jesus','','']
  end
  
  specify 'bridge lyrics should render properly' do
    lines = @bridge_lyric.render_lines
    lines.size.should == 2
    
    lines[0].should == ['Ma-','jes-','ty','']
    lines[1].should == ['Fi-','na-','ly','']
  end
  
end