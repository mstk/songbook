require "#{File.dirname(__FILE__)}/spec_helper"

describe 'chord' do
  
  before(:each) do
    @major_chord = Chord.CHORD(:IV)
    @minor_chord = Chord.CHORD(:vi)
    @hey_jude_chord = Chord.CHORD(:bVII)
    @suspended_chord = Chord.CHORD(:'V-sus')
    @inverted_chord = Chord.CHORD(:'I-2-M7_3')
  end
  
  specify 'Chord::CHORD should return a Chord instance' do
    @major_chord.class.should == Chord
  end
  
  specify 'bad chords should be scolded' do
    lambda { @bad_chord = Chord.CHORD(:VIII) }.should raise_error
  end
  
  specify 'Relativizing chords should be correct' do
    Chord.RELATIVE(:Am,SongKey.KEY(:C)).should == Chord.CHORD(:vi)
    Chord.RELATIVE(:Bb,SongKey.KEY(:C)).should == Chord.CHORD(:bVII)
    Chord.RELATIVE(:'F/A',SongKey.KEY(:C)).should == Chord.CHORD(:IV_3)
    Chord.RELATIVE(:'Gsus-7/B',SongKey.KEY(:C)).should == Chord.CHORD(:'V-sus-7_3')
  end
  
  specify 'chords should render their symbols properly' do
    @major_chord.symbol.should == :IV
    @minor_chord.symbol.should == :vi
    @hey_jude_chord.symbol.should == :bVII
    @suspended_chord.symbol.should == :'V-sus'
    @inverted_chord.symbol.should == :'I-2-M7_3'
  end
  
  specify 'chords should render into keys properly' do
    @major_chord.render_into( SongKey.KEY(:Bb) ).should == :Eb
    @minor_chord.render_into( SongKey.KEY(:A) ).should == :'F#m'
    @hey_jude_chord.render_into( SongKey.KEY(:F) ).should == :'Eb'
    @suspended_chord.render_into( SongKey.KEY(:D) ).should == :'Asus'
    @inverted_chord.render_into( SongKey.KEY(:C) ).should == :'C2-M7/E'
  end
  
end