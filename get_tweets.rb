#!/usr/bin/env ruby

require 'twitter'
require 'sequel'
require 'date'
require 'dotenv'

Dotenv.load

#DB = Sequel.sqlite('test.db')
DB = Sequel.postgres(
  host: ENV['OPENSHIFT_POSTGRESQL_HOST'],
  user: ENV['OPENSHIFT_POSTGRESQL_USERNAME'],
  password: ENV['OPENSHIFT_POSTGRESQL_PASSWORD'],
  database: ENV['OPENSHIFT_APP_NAME']
)

#class Item < Sequel::Model
#end

client = Twitter::REST::Client.new do |config|
  config.consumer_key    = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
end


def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
end

def client.get_all_tweets(user)
  collect_with_max_id do |max_id|
    options = {:count => 200, :include_rts => true}
    options[:max_id] = max_id unless max_id.nil?
    user_timeline(user, options)
  end
end

tweets = client.get_all_tweets(ENV['TWITTER_HANDLE'])

tweets.each do |t|
  item = Item[date: t.created_at.to_date] || Item.new(date: t.created_at.to_date, what:t.text.to_f)
  item.update(what: t.text.to_f)
end
