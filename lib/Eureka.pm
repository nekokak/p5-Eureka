package Eureka;
use strict;
use warnings;

our $VERSION = '0.01';

1;
__DATA__
@@ sql
CREATE TABLE job (
    id            BIGINT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
    func          VARCHAR(255) NULL,
    arg           MEDIUMBLOB,
    enqueue_time  INTEGER UNSIGNED,
    UNIQUE(func)
)
