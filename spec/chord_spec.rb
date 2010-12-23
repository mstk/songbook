require "#{File.dirname(__FILE__)}/spec_helper"

describe 'chord' do
  
  before(:each) do
    @major_chord = Chord.CHORD(:IV)
    @minor_chord = Chord.CHORD(:vi)
    @hey_jude_chord = Chord.CHORD(:bVII)
    @suspended_chord = Chord.CHORD(:'V-sus')
    @inverted_chord = Chord.CHORD(:'I-M7_6')
  end
  
  specify 'Chord::CHORD should return a Chord instance' do
    @major_chord.class.should == Chord
  end
  
  specify 'bad chords should be scolded' do
    lambda { @bad_chord = Chord.CHORD(:VIII) }.should raise_error
  end
  
  specify 'major chord should have a symbol of :IV' do
    @major_chord.symbol.should == :IV
  end

  specify 'minor chord should have a symbol of :vi' do
    @minor_chord.symbol.should == :vi
  end
  
  specify 'hey jude chord should have a symbol of :bVII' do
    @hey_jude_chord.symbol.should == :bVII
  end
  
  specify 'suspended chord should have a symbol of :V-sus' do
    @suspended_chord.symbol.should == :'V-sus'
  end
  
  specify 'inverted chord should have a symbol of :V-M7_6' do
    @inverted_chord.symbol.should == :'I-M7_6'
  end
  
  specify 'major chord should render as :Eb in Bb Major' do
    @major_chord.render_into( SongKey.KEY(:Bb) ).should == :Eb
  end
  
  specify 'minor chord should render as :"F#m" in A Major' do
    @minor_chord.render_into( SongKey.KEY(:A) ).should == "F#m".intern
  end
  
  specify 'hey jude chord should render as :"Eb" in F Major' do
    @hey_jude_chord.render_into( SongKey.KEY(:F) ).should == "Eb".intern
  end
  
  specify 'suspended chord should render as "Asus" in D major' do
    @suspended_chord.render_into( SongKey.KEY(:D) ).should == :'Asus'
  end

  specify 'inverted chord should render as "CM7/E" in C major' do
    @inverted_chord.render_into( SongKey.KEY(:C) ).should == :'CM7/E'
  end
  
end