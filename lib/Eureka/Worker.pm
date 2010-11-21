package Eureka::Worker;
use strict;
use warnings;
use JSON::XS ();

sub new {
    my $class = shift;
    my ($dbhs) = @_;
    $dbhs = [$dbhs] unless ref $dbhs eq 'ARRAY';
    bless {
        dbhs            => $dbhs,
        funcs           => [],
    }, $class;
}

sub add_worker {
    my ($self, $func, $code) = @_;
    push @{$self->{funcs}}, $func;
}

sub dequeue {
    my $self = shift;

    my $sql = sprintf 'SELECT * FROM job WHERE func IN (%s) ORDER BY id LIMIT 1', join( ", ", ("?") x @{$self->{funcs}} );

    for my $dbh ( @{$self->{dbhs}} ) {
        my $row;
        # use Try::Tiny ?
        eval {
            my $sth = $dbh->prepare_cached($sql);
            $sth->execute(@{$self->{funcs}});
            $row = $sth->fetchrow_hashref;
            if ($row) {
                my $sth = $dbh->prepare_cached('DELETE FROM job WHERE id = ?');
                $sth->execute($row->{id});
                if ($sth->rows) {
                    return +{
                        func => $row->{func},
                        JSON::XS::decode_json($row->{arg}),
                    };
                }
            }
        };
        if ($@) {
            # todo: for dead database ?
        }
    }

    return;
}

1;

