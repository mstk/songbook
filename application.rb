require 'sinatra'
require_relative 'environment'

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end

helpers do
  # add your helpers here
end

# root page

get '/' do
  haml :root
end

get '/new_song' do
  haml :new
end

post '/new_song' do
  chord_progression = ChordProgression.first_or_create(:progression => YAML.load(params[:chord_progression].to_yaml))
  
  song_section = Section.create(:chord_progressions => [ chord_progression ])
  
  @song = Song.new(:title => params[:title], :sections => [ song_section ])
  YAML.load("[#{params[:tags]}]").each do |tag|
    @song.tags << Tag.first_or_create(:name => tag)
  end
  
  chord_progression.save
  song_section.save
  
  if @song.save
    redirect "/songs/#{@song.id}"
  else
    redirect '/new_song'
  end
end

get '/songs/:id' do
  @song = Song.get(params[:id])
  if @song
    haml :show
  else
    redirect '/new_song'
  end
end