use strict;
use warnings;
use t::Utils;
use Test::More;
use Test::SharedFork;
use DBI;
use Eureka::Client;
use Eureka::Worker;

my $mysqld = t::Utils->setup;
my $dbh = DBI->connect($mysqld->dsn(dbname => 'test'));

my $client = Eureka::Client->new($dbh);

subtest 'enqueue' => sub {
    my $job_id = $client->enqueue('Mock::Worker1', +{name => 'nekokak'});

    ok $job_id;

    my $sth = $dbh->prepare('SELECT * FROM job WHERE id = ?');
    $sth->execute($job_id);
    my $row = $sth->fetchrow_hashref;

    is $row->{arg}, '{"name":"nekokak"}';
    is $row->{func}, 'Mock::Worker1';

    done_testing;
};

my $worker = Eureka::Worker->new($dbh);

subtest 'add_worker' => sub {
    $worker->add_worker('Mock::Worker1');
    is_deeply $worker->{funcs}, ['Mock::Worker1'];
    done_testing;
};

use Mock::Worker1;
subtest 'run' => sub {

    my $buffer = '';
    open my $fh, '>', \$buffer or die "Could not open in-memory buffer";
    *STDOUT = $fh;

    $worker->run_worker('Mock::Worker1',{name => 'nekokak'});

    close $fh;

    is $buffer, 'nekokak';
    done_testing;
};

t::Utils->cleanup($mysqld);

done_testing;

