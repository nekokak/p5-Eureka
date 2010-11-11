package Eureka::Client;
use strict;
use warnings;
use JSON::XS ();

sub new {
    my $class = shift;
    my ($dbhs) = @_;
    $dbhs = [$dbhs] unless ref $dbhs eq 'ARRAY';
    bless {
        dbhs  => $dbhs,
    }, $class;
}

sub enqueue {
    my ($self, $func, $arg) = @_;

    $arg = JSON::XS::encode_json($arg);

    for my $dbh ( @{ $self->{dbhs} } ) {
        my $jobid;
        eval {
            my $sth = $dbh->prepare_cached('INSERT INTO job (func, arg, enqueue_time) VALUES (?,?,?)');
            $sth->bind_param(1, $func);
            $sth->bind_param(2, $arg);
            $sth->bind_param(3, time);
            $sth->execute();
            $jobid = $dbh->{mysql_insertid};
        };
        return $jobid if defined $jobid;
    }

    return;
}

1;

