require 'sinatra'
require 'sinatra/json'
require 'sinatra/simple_auth'
require 'sequel'
require 'haml'
require 'date'
require 'dotenv'

#Dotenv
Dotenv.load

# connect to the database
DB = Sequel.sqlite('test.db')

#try to create a table, fails if already created
unless DB.table_exists? :items
  DB.create_table :items do
    primary_key :id
    Date :date
    String :what
  end
end

class Item < Sequel::Model
end

set :bind, '0.0.0.0'

set :haml, :format => :html5
enable :sessions
set :session_secret, ENV["APP_SECRET"]
set :password, ENV["APP_PASSWORD"]
set :home, '/'

get '/' do
  protected!
  haml :index
end

get '/login/?' do
  haml :login # page with auth form
end

get '/data' do
  protected!
  json Item.order(:date).map { |item| { date: item.date.iso8601, what: item.what.to_f } }
end

post '/' do
  protected!
  date = Date.parse(params['date']) rescue Date.today
  if params['what'] != "" and params['what'].to_f != 0.0
    item = Item[date: date] || Item.new(date: date, what:params['what'].to_f)
    item.update(what: params['what'].to_f)
  end
  redirect '/'
end
