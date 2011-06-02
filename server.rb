require 'rubygems'
require 'bundler'
Bundler.require

#---[ Settings ]--------------------------------------------------------

# Settings loaded from configuration files.
class Settings < Settingslogic
  source "settings.yml"
end

# Load the model(s)
Dir.glob(['models'].map! {|d| File.join File.expand_path(File.dirname(__FILE__)), d, '*.rb'}).each {|f| require f}


def ar_connect
  db = Settings.database.credentials
  ActiveRecord::Base.establish_connection(
    :adapter  => "mysql", 
    :user     => db.user,
    :database => db.database,
    :password => db.password 
  )
end

ar_connect

get '/' do
  "Hello world, it's #{Time.now} at the server!"
end

get '/foos/:name' do |name|
  # Reconnecting doesn't fix the issue:
  # ActiveRecord::Base.connection.reconnect! unless ActiveRecord::Base.connection.active?
  # ActiveRecord::Base.connection.verify! also does not work.
  #
  # But establishing the connection directly works:
  #ar_connect
  foo = Foo.find_by_name(name)
  "Found Foo: #{foo.name}"
end

get '/foos_sql/:name' do |name|
  res = Foo.get_by_sql(name)
  "Found Foo: #{res.first}"
end
