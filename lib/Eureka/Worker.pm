package Eureka::Worker;
use strict;
use warnings;
use JSON::XS ();

=pod
my $worker = Eureka::Worker->new(
...    
);
$worker->add_worker($func);
$worker->run;
=cut

sub new {
    my $class = shift;
    my ($dbhs) = @_;
    $dbhs = [$dbhs] unless ref $dbhs eq 'ARRAY';
    bless {
        dbhs            => $dbhs,
        funcs           => [],
        signal_received => '',
    }, $class;
}

sub add_worker {
    my ($self, $func, $code) = @_;
    push @{$self->{funcs}}, $func;
}

sub run_worker {
    my ($self, $func, $row) = @_;

    eval { $func->work($row) };
    if ($@) {
        Carp::croak("failed $func : $@");
    }
}

sub run {
    my $self = shift;

    local $SIG{TERM} = sub {
        $self->{signal_received} = $_[0];
    };

    my $sql = sprintf 'SELECT * FROM job WHERE func IN (%s) ORDER BY id LIMIT 1', join( ", ", ("?") x @{$self->{funcs}} );

    while (1) {
        for my $dbh ( @{$self->{dbhs}} ) {
            my $row;
            eval {
                my $sth = $dbh->prepare_cached($sql);
                my $i = 1;
                for my $func (@{$self->{funcs}}) {
                    $sth->bind_param($i++, $func);
                }
                $sth->execute();
                $row = $sth->fetchrow_hashref;
            };
            if ($row) {
                my $sth = $dbh->prepare_cached('DELETE FROM job WHERE id = ?');
                $sth->execute($row->{id});
                $self->run_worker($row->{func}, JSON::XS::decode_json($row->{arg}));
            }

            if ($self->{signal_received}) {
                return;
            }
        }
    }
}

1;

