# TODO: Migrate this all to an external YAML file someday.

##### INITIAL COLOR SCHEMES #######
{ :default  => [nil,:flat ,nil,nil,:sharp,nil,:flat ,nil,nil,:sharp,nil,:flat ],
  :keyboard => [nil,:flat ,nil,nil,:flat ,nil,:flat ,nil,nil,:sharp,nil,:flat ],
  :string   => [nil,:sharp,nil,nil,:sharp,nil,:sharp,nil,nil,:sharp,nil,:sharp],
  :flats    => [nil,:flat ,nil,nil,:flat ,nil,:flat ,nil,nil,:flat ,nil,:flat ], 
  :sharps   => [nil,:sharp,nil,nil,:sharp,nil,:sharp,nil,nil,:sharp,nil,:sharp] }.each do |name,scheme|  
    new_color_scheme = ColorScheme.first_or_create(:name => name.to_s, :scheme => scheme )
  end

## FIRST SONG ##
  
structure = [ { :type => "INTRO" },
              { :type => "VERSE", :lyric_variation => 1 },
              { :type => "PRECHORUS" },
              { :type => "CHORUS" },
              { :type => "VERSE", :lyric_variation => 2 },
              { :type => "PRECHORUS" },
              { :type => "CHORUS", :repeat => 2 },
              { :type => "BRIDGE", :repeat => 3 },
              { :type => "CHORUS", :repeat => 2, :modulation => 2 } ]

bbyn = Song.create( :title => 'Blessed Be Your Name', :song_key => SongKey.KEY( :Bb ), :structure => structure )

prog_1 = ChordProgression.first_or_create(:progression => [:I,:V,:vi,:IV] )
prog_2 = ChordProgression.first_or_create(:progression => [:I,:V,:IV,:IV] )
prog_3 = ChordProgression.first_or_create(:progression => [:I,:I,:V,:V,:vi,:V,:IV,:IV] )

intro      = Section.build( :type => "INTRO", :progressions => [prog_1], :song => bbyn )
verse      = Section.build( :type => "VERSE", :progressions => [prog_1,prog_2] * 2, :song => bbyn )
prechorus  = Section.build( :type => "PRECHORUS", :progressions => [prog_1,prog_1], :song => bbyn )
chorus     = Section.build( :type => "CHORUS", :progressions => [prog_1,prog_3], :song => bbyn )
bridge     = Section.build( :type => "BRIDGE", :progressions => [prog_1,prog_1], :song => bbyn )

puts "All is properly seeded!"