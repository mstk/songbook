require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'rspec'
require 'rack/test'

# set test environment
Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

require File.join(File.dirname(__FILE__), '../application')

# establish in-memory database for testing
DataMapper.setup(:default, "sqlite3::memory:")

Rspec.configure do |config|
  # reset database before each example is run
  config.before(:each) do
    DataMapper.auto_migrate!
    require "#{File.dirname(__FILE__)}/../db/seed"
    
    { :default  => [nil,:flat ,nil,nil,:sharp,nil,:flat ,nil,nil,:sharp,nil,:flat ],
      :keyboard => [nil,:flat ,nil,nil,:flat ,nil,:flat ,nil,nil,:sharp,nil,:flat ],
      :string   => [nil,:sharp,nil,nil,:sharp,nil,:sharp,nil,nil,:sharp,nil,:sharp],
      :flats    => [nil,:flat ,nil,nil,:flat ,nil,:flat ,nil,nil,:flat ,nil,:flat ], 
      :sharps   => [nil,:sharp,nil,nil,:sharp,nil,:sharp,nil,nil,:sharp,nil,:sharp] }.each do |name,scheme|  
        new_color_scheme = ColorScheme.first_or_create(:name => name.to_s, :scheme => scheme )
        new_color_scheme.save
      end
    
  end
end