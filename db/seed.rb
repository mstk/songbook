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

bbyn = SongPacket.new(:title => 'Blessed Be Your Name', :artist => 'Matt Redman', :song_key => 'Bb')
bbyn.set_structure(structure)

bbyn.add_section('INTRO', [['Bb','F','Gm','Eb']] * 3 + [['Bb','F','Eb','Eb']] )
bbyn.add_section('VERSE', [[:I,:V,:vi,:IV],[:I,:V,:IV,:IV]] * 2 )
bbyn.add_section('PRECHORUS', [[:I,:V,:vi,:IV]] * 2 )
bbyn.add_section('CHORUS', [[:I,:V,:vi,:IV],[:I,:I,:V,:V,:vi,:V,:IV,:IV]] )
bbyn.add_section('BRIDGE', [[:I,:V,:vi,:IV]] * 2 )

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

When the
world's "all as it
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
 still I will
say
PRECHORUS

chorus_text = <<CHORUS
Blessed be the
name of the
Lord, Blessed be your
name

Blessed be the
name of the
Lord, Blessed be your
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

bbyn.add_lyric(verse_1_text,'VERSE',1)
bbyn.add_lyric(verse_2_text,'VERSE',2)
bbyn.add_lyric(prechorus_text,'PRECHORUS')
bbyn.add_lyric(chorus_text,'CHORUS')
bbyn.add_lyric(bridge_text,'BRIDGE')

bbyn.build!

puts "All is properly seeded!"