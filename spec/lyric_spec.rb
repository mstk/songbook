require "#{File.dirname(__FILE__)}/spec_helper"

describe 'lyric' do
  
  before(:each) do
    chorus_lyric_text = "Here is our King\nHere is our Love\nHere is our God whose come\nto bring us back to Him\n\n"
    chorus_lyric_text += "He is the one\nHe is Jesus"
    bridge_lyric_text = "Ma-\njes-\nty\n\nFi-\nna-\nly"
    
    @chorus_lyric = Lyric.parse( chorus_lyric_text,0) # 0 (count) isn't required. just making
    @bridge_lyric = Lyric.parse( bridge_lyric_text)   # sure it works both ways.
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