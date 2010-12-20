# SO UGLY
#
module KeyScale
  
  NATURALS = %w[ A B C D E F G ].map { |n| n.intern }
  
  # Gives the order of keys in the Circle of Fifths in the given color.  A key's index on the
  # array is the number of accidentals in the key.
  CIRCLE_OF_FIFTHS =  { :flat  => (0..11).map { |n| (3 - 7*n) % 12 },
                        :sharp => (0..11).map { |n| (3 + 7*n) % 12 } }
  
  # A key with `n` accidentals has all of the first `n` accidentals in the given array of the 
  # corresponding color.
  ACCIDENTALS = { :flat  => (0..6).map { |n| 3 + (n-1)*4 },
                  :sharp => (0..6).map { |n| 6 + (n-1)*3 } }
  
  COLOR_VALUE  = {  :flat  => -1,
                    :sharp =>  1 }
  COLOR_STRING = {  :flat  => "b",
                    :sharp => "#" }
  
  KEY_SCALES = Hash.new do |h,song_key|
    h[song_key] = Hash.new do |i,color|
      generate_scale(song_key,color)
    end
  end
  
  NATURALS.freeze
  
  def generate_scale(song_key, color = :flat)
    scale_accidentals = Array.new(7) { 0 }
    
    root_natural = song_key.natural(ColorScheme.get_all(color))
    natural_id = NATURALS.index(root_natural)
    
    # fill the scale accidentals
    number_of_accidentals = CIRCLE_OF_FIFTHS[color].index(song_key.key_id)
    number_of_accidentals.times { |n| scale_accidentals[ACCIDENTALS[color][n]] += COLOR_VALUE[color] }
    
    # map scale accidentals to actual scale, by steps
    return (0..6).map { |step| "#{NATURALS[(natural_id + step) % 7]}#{COLOR_STRING[color] * scale_accidentals[step].abs}".intern }
  end
  
end