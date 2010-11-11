use inc::Module::Install;
name 'Eureka';
all_from 'lib/Eureka.pm';

requires 'DBI';
requires 'JSON::XS';

test_requires 'Test::More' => '0.94';
test_requires 'Module::Install::TestTarget' => '0.14';
test_requires 'Test::mysqld' => '0.11';
test_requires 'Data::Section::Simple';

tests 't/*t';

default_test_target
    includes       => ['t/lib'],
    run_on_prepare => ['t/start_mysqld.pl'],
;

auto_set_repository;

WriteAll;

