require 'sinatra'
require 'sinatra/contrib'
require 'bcrypt'
require 'time'

require_relative 'db_persistence'

configure do
	enable :sessions
	set :session_secret, 'secret'
	set :erb, :escape_html => true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "db_persistence.rb"
end

before do
  @storage = Database.new(logger)
end

after do
  @storage.disconnect
end

get '/' do
	redirect '/jhorch'
end

get '/jhorch' do
	@posts = @storage.get_all_posts('jhorch').sort_by { |period| -period[:id].to_i }
	erb :jhorch, layout: :layout
end

get '/create_post' do
	
	erb :create_post, layout: :layout
end

post '/create_post' do
	@storage.add_post(params[:message], params[:name], params[:class])
	session[:success] = 'You have posted to the blog successfully!'

	redirect '/create_post'
end

get '/delete_post' do
	@posts = @storage.get_all_posts('jhorch').sort_by { |period| -period[:id].to_i }

	erb :delete_post, layout: :layout
end

post '/delete_post' do
	# params.inspect
	@storage.delete_post(params[:class_id])
	session[:success] = 'You have deleted a post from the blog.'
	
	redirect '/delete_post'
end