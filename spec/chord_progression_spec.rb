require "#{File.dirname(__FILE__)}/spec_helper"

describe 'chord_progression' do
  
  before(:each) do
    @basic_progression = ChordProgression.first_or_create(:progression => [:I,:V,:vi,:IV])
  end
  
  specify 'should render properly in a flat key' do
    @basic_progression.render_into(SongKey.KEY(:Bb)).should == [:Bb,:F,:Gm,:Eb]
  end
  
  specify 'should render properly in a sharp key' do
    @basic_progression.render_into(SongKey.KEY(:A)).should == [:A,:E,:"F#m",:D]
  end
  
end