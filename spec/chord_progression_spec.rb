require "#{File.dirname(__FILE__)}/spec_helper"

describe 'chord_progression' do
  
  before(:each) do
    @basic_progression = ChordProgression.first_or_create(:progression => [:I,:V,:vi,:IV])
    @repeat_progression = ChordProgression.first_or_create(:progression => [:IV,:IV,:IV,:IV,:V,:V,:vi,:V])
  end
  
  specify 'should render properly in a flat key' do
    @basic_progression.render_into(SongKey.KEY(:Bb)).should == [:Bb,:F,:Gm,:Eb]
  end
  
  specify 'should render properly in a sharp key' do
    @basic_progression.render_into(SongKey.KEY(:A)).should == [:A,:E,:"F#m",:D]
  end
  
  specify 'should give the right repeat structure' do
    @basic_progression.repeat_structure.should == [1,1,1,1]
    @repeat_progression.repeat_structure.should == [4,2,1,1]
  end
  
end