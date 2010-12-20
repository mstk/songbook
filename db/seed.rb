# TODO: Migrate this all to an external YAML file someday.

##### INITIAL COLOR SCHEMES #######
{ :default  => [nil,:flat ,nil,nil,:sharp,nil,:flat ,nil,nil,:sharp,nil,:flat ],
  :keyboard => [nil,:flat ,nil,nil,:flat ,nil,:flat ,nil,nil,:sharp,nil,:flat ],
  :string   => [nil,:sharp,nil,nil,:sharp,nil,:sharp,nil,nil,:sharp,nil,:sharp],
  :flats    => [nil,:flat ,nil,nil,:flat ,nil,:flat ,nil,nil,:flat ,nil,:flat ], 
  :sharps   => [nil,:sharp,nil,nil,:sharp,nil,:sharp,nil,nil,:sharp,nil,:sharp] }.each do |name,scheme|  
    ColorScheme.first_or_create(:name => name.to_s, :scheme => scheme )
  end