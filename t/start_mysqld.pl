#! perl
use t::Utils;
use JSON::XS;
use DBI;

$SIG{INT} = sub { CORE::exit 1 };
$mysqld = t::Utils->setup;
$ENV{TEST_MYSQLD} = encode_json +{ %$mysqld };

my $dbh = DBI->connect($mysqld->dsn(dbname => 'test'));
$dbh->do(
q{CREATE TABLE job (
    id            BIGINT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
    func          VARCHAR(255) NULL,
    arg           MEDIUMBLOB,
    enqueue_time  INTEGER UNSIGNED
)}
);

