require 'bundler/setup'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-migrations'
require 'ostruct'

require 'sinatra' unless defined?(Sinatra)
require 'haml'
require 'yaml'

configure do
  SiteConfig = OpenStruct.new(
                 :title => 'Song Database',
                 :author => 'Justin Le',
                 :url_base => 'http://localhost:4567/'
               )
  
  DataMapper::Logger.new(STDOUT, :debug)
  
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/songdb.sqlite3")
  # DataMapper.setup(:default, (ENV["DATABASE_URL"] || "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/#{Sinatra::Base.environment}.db"))
  
  require 'models'
  
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
  Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }
  
  DataMapper.finalize
  
  require "#{File.dirname(__FILE__)}/db/seed.rb"
  
end