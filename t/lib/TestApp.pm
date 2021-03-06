package t::lib::TestApp;

use Dancer;
use Dancer::Plugin::Database;
use Test::More import => ['!pass']; # import avoids 'prototype mismatch' with Dancer
use File::Temp qw(tempfile);

my $db_fh = File::Temp->new( EXLOCK => 0 );

config->{plugins}{Database}{driver} = "SQLite";
config->{plugins}{Database}{database} = $db_fh->filename;

BEGIN {
    use_ok( 'Dancer::Plugin::SimpleCRUD' ) || die "Can't load Dancer::Plugin::SimpleCrud. Bail out!\n";
}
my $password = "{SSHA}LfvBweDp3ieVPRjAUeWikwpaF6NoiTSK";     # password is 'tester'
my @sql = (
    #q/drop table if exists users/,
    qq/create table users (id INTEGER, username VARCHAR, password VARCHAR)/,
    qq/insert into users values (1, 'sukria', '$password')/,
    qq/insert into users values (2, 'bigpresh', '$password')/,
    qq/insert into users values (3, 'badger', '$password')/,
    qq/insert into users values (4, 'bodger', '$password')/,
    qq/insert into users values (5, 'mousey', '$password')/,
    qq/insert into users values (6, 'mystery2', '$password')/,
    qq/insert into users values (7, 'mystery1', '$password')/,
);

database->do($_) for @sql;

my $custom_column = { name => 'extra', raw_column => 'id', transform => sub { "Hello, id: $_[0]" }, column_class=>"classhere" };
# now set up our simple_crud interfaci
simple_crud( prefix => '/users'  ,              record_title=>'A', db_table => 'users', editable => 0, );
simple_crud( prefix => '/users_editable',       record_title=>'A', db_table => 'users', editable => 1, );
simple_crud( prefix => '/users_editable_not_addable',       
                                                record_title=>'A', db_table => 'users', editable => 1, addable => 0);
simple_crud( prefix => '/users_custom_columns', record_title=>'A', db_table => 'users', editable => 0, custom_columns => [ $custom_column ] );

# override display of 'username' column
simple_crud( prefix => '/users_customized_column', record_title=>'A', db_table => 'users', editable => 0, sortable=>1,
                custom_columns => [ { name => "username", raw_column=>"username", transform => sub { "Username: $_[0]" }, column_class=>"classhere" } ], 
            );

1;
