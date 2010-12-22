require "#{File.dirname(__FILE__)}/spec_helper"

describe 'song_key' do
  before(:each) do
    @key = SongKey.KEY(:Bb)
  end
  
  specify 'SongKey::KEY should be a SongKey resource' do
    @key.class.should == SongKey
  end

  specify 'should have id 1' do
    @key.key_id.should == 1
  end

  specify 'should have a symbol of A# in sharp colors' do
    @key.symbol(ColorScheme.get('sharps')).should == 'A#'.intern
  end
  
  specify 'should have a symbol of Bb in flat colors' do
    @key.symbol(ColorScheme.get('flats')).should == 'Bb'.intern
  end
  
  specify 'should have a fourth scale note of Eb in the default color scheme' do
    @key.render_step(3).should == 'Eb'.intern
  end
end