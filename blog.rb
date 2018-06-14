require 'sinatra'
require 'sinatra/contrib'
require 'bcrypt'
require 'time'

require_relative 'db_persistence'

set :template_engines, {
  :css=>[],
  :xml=>[],
  :js=>[],
  :html=>[:erb],
  :all=>[:erb],
  :json=>[]
}

configure do
	enable :sessions
	set :session_secret, 'secret'
	set :erb, :escape_html => true
	# set :template_engine, :erb
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

def logged_in?
	!session[:username].nil?
end

def convert_time(time)
	t = Time.parse(time)
	t.strftime("%I:%M%p")
end

def get_year(time)
	t = Time.parse(time)
	t.strftime("%m/%e/%Y")
end

get '/dashboard' do
	if logged_in?
		@periods = @storage.get_all_periods

		erb :dashboard, layout: :layout
	else
		session[:message] = 'Please log in to access this area.'
		redirect '/login'
	end
end

get '/blog/:group' do
	@posts = @storage.get_all_posts(params[:group]).sort_by { |period| -period[:id].to_i }

	erb :jhorch, layout: :layout
end


get '/create_post' do
	if logged_in?
		erb :create_post, layout: :layout
	else
		session[:message] = 'Please log in to access this area.'
		redirect '/login'
	end
end

post '/create_post' do
	@storage.add_post(params[:message], params[:name], params[:class])
	session[:success] = 'You have posted to the blog successfully!'

	redirect '/create_post'
end

get '/delete_post/:group' do
	@posts = @storage.get_all_posts(params[:group]).sort_by { |period| -period[:id].to_i }

	erb :delete_post, layout: :layout
end

post '/delete_post' do
	# params.inspect
	@storage.delete_post(params[:class_id])
	session[:success] = 'You have deleted a post from the blog.'
	
	redirect '/delete_post'
end

get '/login' do

	erb :login, layout: :layout
end

post '/login' do
	result = @storage.get_user(params[:username]).reduce

	if result
		check = BCrypt::Password.new(result[:password])
		if check = params[:password]
			session[:username] = params[:username]
			session[:success] = "You are logged in #{session[:username]}"

			redirect '/dashboard'
		end
	end

	session[:error] = "Incorrect username or password. Please try again."

	redirect '/login'
end

get '/signup' do
	@number_of_users = @storage.check_number_users.reduce[:number_of_users].to_i

	erb :signup, layout: :layout
end

post '/signup' do
	password = BCrypt::Password.create(params[:password])

	@storage.add_user(params[:username], password)
	session[:success] = "You have signed-up. Please log in to use the system."

	redirect '/login'
end

post '/logout' do
	old_user = session[:username]
	session.clear
	session[:message] = "#{old_user} has been logged out."
	redirect '/login'
end

