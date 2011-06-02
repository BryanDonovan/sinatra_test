mysql -u root -e "drop database sinatra_test"
mysqladmin -u root create sinatra_test
mysql -u root sinatra_test -e "create table foos(id int auto_increment primary key, name varchar(20), index(name))"
mysql -u root sinatra_test -e "insert into foos (name) values ('buzz'), ('bar'), ('widget')"
