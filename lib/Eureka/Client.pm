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

            my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
            my $time = sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
            $sth->execute($func, $arg, $time);
            $jobid = $dbh->{mysql_insertid};
        };
        return $jobid if defined $jobid;
    }

    return;
}

1;

