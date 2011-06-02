class Foo < ActiveRecord::Base
	def self.get_by_sql(name)
		query = "select name from foos where name = '#{name}'"
		db = Settings.database.credentials
    conn = Mysql.real_connect(db.host, db.user, db.password, db.database)
		conn.query(query).fetch_row
	ensure
    conn.close if conn
	end
end
