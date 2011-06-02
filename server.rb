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

db = Settings.database.credentials
ActiveRecord::Base.establish_connection(:adapter  => "mysql", 
                                        :user     => db.user,
                                        :database => db.database,
                                        :password => db.password 
                                       )

get '/' do
  "Hello world, it's #{Time.now} at the server!"
end

get '/foos/:name' do |name|
  foo = Foo.find_by_name(name)
  "Found Foo: #{foo.name}"
end

get '/foos_sql/:name' do |name|
  res = Foo.get_by_sql(name)
  "Found Foo: #{res.first}"
end
