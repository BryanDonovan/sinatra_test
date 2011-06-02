Quick Sinatra application that tests using ActiveRecord to connect to MySQL, running on Mongrel.

=Setup
bundle install
./setup.sh

That assumes you have a MySQL database on localhost with user root and an empty password.
Otherwise, you'll have to edit the settings.yml file and the setup.sh file with correct database params.


=What's the Point?

The point is that I have a Rails metal app running on sinatra, and noticed I was getting strange 5-second requests on 
every 5th request or so. This application is an attempt to isolate the problem. See Benchmarks section below.

=The "Solution"
If I establish a new ActiveRecord connection on each request, the problem goes away.  
Using ActiveRecord::Base.connection.reconnect! does not fix the issue.

Update: Setting a wait_timeout and/or pool values in the ActiveRecord connection change this behavior 
(not surprisingly).  See server.rb.

=Key Gems

The key gems used are:
gem 'mongrel'      , '1.1.5'
gem 'sinatra'      , '1.2.6'
gem 'mysql'        , '2.8.1'
gem 'activerecord' , '2.3.11', :require => 'active_record'

=Benchmarks

On my local laptop (MacBook Pro):

First, hitting a URL that gets a Foo record via ActiveRecord:
foo = Foo.find_by_name(name)

$ ab -n 10 -c 1 http://127.0.0.1:4567/foos/bar

127.0.0.1 - - [02/Jun/2011 12:23:23] "GET /foos/bar HTTP/1.0" 200 14 0.0015
127.0.0.1 - - [02/Jun/2011 12:23:23] "GET /foos/bar HTTP/1.0" 200 14 0.0012
127.0.0.1 - - [02/Jun/2011 12:23:23] "GET /foos/bar HTTP/1.0" 200 14 0.0011
127.0.0.1 - - [02/Jun/2011 12:23:23] "GET /foos/bar HTTP/1.0" 200 14 0.0011
*127.0.0.1 - - [02/Jun/2011 12:23:28] "GET /foos/bar HTTP/1.0" 200 14 5.0029
127.0.0.1 - - [02/Jun/2011 12:23:28] "GET /foos/bar HTTP/1.0" 200 14 0.0015
127.0.0.1 - - [02/Jun/2011 12:23:28] "GET /foos/bar HTTP/1.0" 200 14 0.0013
127.0.0.1 - - [02/Jun/2011 12:23:28] "GET /foos/bar HTTP/1.0" 200 14 0.0013
127.0.0.1 - - [02/Jun/2011 12:23:28] "GET /foos/bar HTTP/1.0" 200 14 0.0014
*127.0.0.1 - - [02/Jun/2011 12:23:33] "GET /foos/bar HTTP/1.0" 200 14 5.0032

Notice that the 5th and tenth request are almost exactly 5 seconds more than the others. This is reproducible 100% of the 
times I run this benchmark, or by reloading in the browser directly.

If I use the Mysql Gem directly and avoid ActiveRecord, the problem goes away:

ab -n 10 -c 1 http://127.0.0.1:4567/foos_sql/bar

127.0.0.1 - - [02/Jun/2011 13:12:06] "GET /foos_sql/bar HTTP/1.0" 200 14 0.0011
127.0.0.1 - - [02/Jun/2011 13:12:06] "GET /foos_sql/bar HTTP/1.0" 200 14 0.0009
127.0.0.1 - - [02/Jun/2011 13:12:06] "GET /foos_sql/bar HTTP/1.0" 200 14 0.0009
127.0.0.1 - - [02/Jun/2011 13:12:06] "GET /foos_sql/bar HTTP/1.0" 200 14 0.0009
127.0.0.1 - - [02/Jun/2011 13:12:06] "GET /foos_sql/bar HTTP/1.0" 200 14 0.0010
127.0.0.1 - - [02/Jun/2011 13:12:06] "GET /foos_sql/bar HTTP/1.0" 200 14 0.0014
127.0.0.1 - - [02/Jun/2011 13:12:06] "GET /foos_sql/bar HTTP/1.0" 200 14 0.0011
127.0.0.1 - - [02/Jun/2011 13:12:06] "GET /foos_sql/bar HTTP/1.0" 200 14 0.0009
127.0.0.1 - - [02/Jun/2011 13:12:06] "GET /foos_sql/bar HTTP/1.0" 200 14 0.0010
127.0.0.1 - - [02/Jun/2011 13:12:06] "GET /foos_sql/bar HTTP/1.0" 200 14 0.0009

Also, if I change the server to thin instead of mongrel, the problem goes away when using ActiveRecord:

127.0.0.1 - - [02/Jun/2011 13:15:00] "GET /foos/bar HTTP/1.0" 200 14 0.0265
127.0.0.1 - - [02/Jun/2011 13:15:00] "GET /foos/bar HTTP/1.0" 200 14 0.0011
127.0.0.1 - - [02/Jun/2011 13:15:00] "GET /foos/bar HTTP/1.0" 200 14 0.0009
127.0.0.1 - - [02/Jun/2011 13:15:00] "GET /foos/bar HTTP/1.0" 200 14 0.0009
127.0.0.1 - - [02/Jun/2011 13:15:00] "GET /foos/bar HTTP/1.0" 200 14 0.0009
127.0.0.1 - - [02/Jun/2011 13:15:00] "GET /foos/bar HTTP/1.0" 200 14 0.0009
127.0.0.1 - - [02/Jun/2011 13:15:00] "GET /foos/bar HTTP/1.0" 200 14 0.0009
127.0.0.1 - - [02/Jun/2011 13:15:00] "GET /foos/bar HTTP/1.0" 200 14 0.0009
127.0.0.1 - - [02/Jun/2011 13:15:00] "GET /foos/bar HTTP/1.0" 200 14 0.0009
127.0.0.1 - - [02/Jun/2011 13:15:00] "GET /foos/bar HTTP/1.0" 200 14 0.0010
