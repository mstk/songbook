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

intro      = Section.build( :type => "INTRO", :progressions => [prog_1,prog_1,prog_1,prog_2], :song => bbyn )
verse      = Section.build( :type => "VERSE", :progressions => [prog_1,prog_2] * 2, :song => bbyn )
prechorus  = Section.build( :type => "PRECHORUS", :progressions => [prog_1,prog_1], :song => bbyn )
chorus     = Section.build( :type => "CHORUS", :progressions => [prog_1,prog_3], :song => bbyn )
bridge     = Section.build( :type => "BRIDGE", :progressions => [prog_1,prog_1], :song => bbyn )


verse_1_text = <<VERSE
 
 Blessed be
 Your name, in the
land that is
plentiful

Where Your
streams of a-
bundance flow, blessed be
Your name

 
 Blessed be
 Your name, when I'm
found in the de-
sert place

Though I
walk through the wild-
erness, blessed be
Your name
VERSE

verse_2_text = <<VERSE
 
 Blessed be
 Your name, when the
sun's shining down
on me

When the world's
"all as it
should be", blessed be
Your name

 
 Blessed be
 Your name, on the
road marked with suf-
fering

Though there's pain
in the of-
fering, blessed be
Your name
VERSE

prechorus_text = <<PRECHORUS
 
 Every blessing
you pour out I'll
 turn back to
praise

 
 When the darkness
closes in, Lord,
 still I will say
PRECHORUS

chorus_text = <<CHORUS
Blessed be the
name of the
Lord, Blessed be your
name

Blessed be the
name
of the
Lord,
Blessed be your
Glo-
rious
name
CHORUS

bridge_text = <<BRIDGE
You
give and take a-
way, you
give and take a-
way

My
heart will choose to
say, "Lord,
blessed be your
name"
BRIDGE

Lyric.build( verse_1_text, verse, 1 )
Lyric.build( verse_2_text, verse, 2 )
Lyric.build( prechorus_text, prechorus )
Lyric.build( chorus_text, chorus )
Lyric.build( bridge_text, bridge )

puts "All is properly seeded!"