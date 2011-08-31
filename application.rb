require 'sinatra'
require 'json'
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
  haml :index
end

get '/new_song/?' do
  haml :new_song
end

post '/new_song/?' do
  # chord_progression = ChordProgression.first_or_create(:progression => YAML.load(params[:chord_progression].to_yaml))
  
  packet = SongPacket.new(:title => params[:song_title],
                          :artist => params[:artist],
                          :song_key => params[:key],
                          :time_signature => params[:time_signature])
  
  
  # tags = YAML.load("[#{params[:tags]}]").map do |tag|
    # Tag.first_or_create(:name => tag)
  # end
  
  @song = packet.build
  
  return @song.id.to_json
end

get '/edit_song/:id' do
  @song = Song.get(params[:id])
  if @song
    haml :edit_song
  else
    redirect '/songs/'
  end
end

get '/songs/?' do
  haml :song_list
end

get '/songs/:id' do
  @song = Song.get(params[:id])
  @rendered_sections = @song.render_sections
  if @song
    haml :show_song
  else
    redirect '/songs'
  end
end

######## AJAX ########

post '/ajax/song_data/?' do
  ## handle bad songs
  @song = Song.get(params[:id].to_i)
  
  ## this doesn't work but w/e
  to_render = [:info,:sections,:structure].select { |n| params[n] }
  
  @data = @song.render_data(to_render)
  
  return @data.to_json
end