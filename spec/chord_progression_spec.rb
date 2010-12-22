require "#{File.dirname(__FILE__)}/spec_helper"

describe 'chord_progression' do
  
  before(:each) do
    @basic_progression = ChordProgression.first_or_create(:progression => [:I,:V,:vi,:IV])
    @basic_progression.save
  end
  
  specify 'should render properly in a flat key' do
    @basic_progression.render_into(SongKey.KEY(:Bb),ColorScheme.get_scheme_all(:flat)).should == [:Bb,:F,:Gm,:Eb]
  end
  
  specify 'should render properly in a sharp key' do
    @basic_progression.render_into(SongKey.KEY(:A),ColorScheme.get_scheme_all(:flat)).should == [:A,:E,:"F#m",:D]
  end
  
end