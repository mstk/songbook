require "#{File.dirname(__FILE__)}/spec_helper"

describe 'song' do
  
  before(:each) do
    
    @structure = [ { :type => "INTRO" },
                   { :type => "VERSE", :lyric_variation => 1 },
                   { :type => "PRECHORUS" },
                   { :type => "CHORUS" },
                   { :type => "VERSE", :lyric_variation => 2 },
                   { :type => "PRECHORUS" },
                   { :type => "CHORUS", :repeat => 2 },
                   { :type => "BRIDGE", :repeat => 3 },
                   { :type => "CHORUS", :repeat => 2, :modulation => 2 } ]
    
    @bbyn = Song.create( :title => 'Blessed Be Your Name', :song_key => SongKey.KEY( :Bb ), :structure => @structure )
    
    prog_1 = ChordProgression.first_or_create(:progression => [:I,:V,:vi,:IV] )
    prog_2 = ChordProgression.first_or_create(:progression => [:I,:V,:IV,:IV] )
    prog_3 = ChordProgression.first_or_create(:progression => [:I,:I,:V,:V,:vi,:V,:IV,:IV] )
    
    @intro      = Section.build( :type => "INTRO", :progressions => [prog_1], :song => @bbyn )
    @verse      = Section.build( :type => "VERSE", :progressions => [prog_1,prog_2] * 2, :song => @bbyn )
    @prechorus  = Section.build( :type => "PRECHORUS", :progressions => [prog_1,prog_1], :song => @bbyn )
    @chorus     = Section.build( :type => "CHORUS", :progressions => [prog_1,prog_3], :song => @bbyn )
    @bridge     = Section.build( :type => "BRIDGE", :progressions => [prog_1,prog_1], :song => @bbyn )
    
    @rendered_sections = @bbyn.render_sections
  end
  
  specify 'intro renders properly' do
    rendered = @rendered_sections[0]
    
    rendered[:title].should == "INTRO"
    rendered[:lines][0][:chords].should == [:Bb,:F,:Gm,:Eb]
    
  end
  
  specify 'verse 1 renders properly' do
    rendered = @rendered_sections[1]
    
    rendered[:title].should == "VERSE 1"
    rendered[:lines][0][:chords].should == [:Bb,:F,:Gm,:Eb]
    rendered[:lines][1][:chords].should == [:Bb,:F,:Eb,:'']
  end
  
  specify 'prechorus 1 renders properly' do
    rendered = @rendered_sections[2]
    
    rendered[:title].should == "PRECHORUS"
    rendered[:lines][0][:chords].should == [:Bb,:F,:Gm,:Eb]
    rendered[:lines][1][:chords].should == [:Bb,:F,:Gm,:Eb]
  end
  
  specify 'chorus 1 renders properly' do
    rendered = @rendered_sections[3]
    
    rendered[:title].should == "CHORUS"
    rendered[:lines][0][:chords].should == [:Bb,:F,:Gm,:Eb]
    rendered[:lines][1][:chords].should == [:Bb,:'',:F,:'',:Gm,:F,:Eb,:'']
  end
  
  specify 'verse 2 renders properly' do
    rendered = @rendered_sections[4]
    
    rendered[:title].should == "VERSE 2"
    rendered[:lines][0][:chords].should == [:Bb,:F,:Gm,:Eb]
    rendered[:lines][1][:chords].should == [:Bb,:F,:Eb,:'']
  end
  
  specify 'prechorus 2 renders properly' do
    rendered = @rendered_sections[5]
    
    rendered[:title].should == "PRECHORUS"
    rendered[:lines][0][:chords].should == [:Bb,:F,:Gm,:Eb]
    rendered[:lines][1][:chords].should == [:Bb,:F,:Gm,:Eb]
  end
  
  specify 'chorus 2 renders properly' do
    rendered = @rendered_sections[6]
    
    rendered[:title].should == "CHORUS"
    rendered[:lines][0][:chords].should == [:Bb,:F,:Gm,:Eb]
    rendered[:lines][1][:chords].should == [:Bb,:'',:F,:'',:Gm,:F,:Eb,:'']
    rendered[:lines][2][:chords].should == [:Bb,:F,:Gm,:Eb]
    rendered[:lines][3][:chords].should == [:Bb,:'',:F,:'',:Gm,:F,:Eb,:'']
  end
  
  specify 'bridge renders properly' do
    rendered = @rendered_sections[7]
    
    rendered[:title].should == "BRIDGE"
    rendered[:lines][0][:chords].should == [:Bb,:F,:Gm,:Eb]
    rendered[:lines][1][:chords].should == [:Bb,:F,:Gm,:Eb]
    rendered[:lines][2][:chords].should == [:Bb,:F,:Gm,:Eb]
    rendered[:lines][3][:chords].should == [:Bb,:F,:Gm,:Eb]
    rendered[:lines][4][:chords].should == [:Bb,:F,:Gm,:Eb]
    rendered[:lines][5][:chords].should == [:Bb,:F,:Gm,:Eb]
  end
  
  specify 'chorus 3 renders properly' do
    rendered = @rendered_sections[8]
    
    rendered[:title].should == "CHORUS"
    rendered[:lines][0][:chords].should == [:C,:G,:Am,:F]
    rendered[:lines][1][:chords].should == [:C,:'',:G,:'',:Am,:G,:F,:'']
    rendered[:lines][2][:chords].should == [:C,:G,:Am,:F]
    rendered[:lines][3][:chords].should == [:C,:'',:G,:'',:Am,:G,:F,:'']
  end
  
end