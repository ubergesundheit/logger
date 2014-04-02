require './get_tweets'
require './logger'

# serve d3 through rack
map "/d3.js" do
    run Rack::File.new("./d3.v3.min.js")
end

set :environment, :production

#log = File.new("sinatra.log", "a")
#log.sync = true
#$stdout.reopen(log)
#$stderr.reopen(log)

set :haml, :format => :html5
enable :sessions
set :session_secret, ENV["APP_SECRET"]
set :password, ENV["APP_PASSWORD"]
set :home, '/'

run Sinatra::Application
