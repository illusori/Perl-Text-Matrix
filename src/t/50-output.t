#!perl -T

use strict;
use warnings;

use Test::More;

use Text::Matrix;

my $rows = [ map { "Row $_" } ( 1..3 ) ];
my $cols = [ map { "Column $_" } ( 1..3 ) ];
my $data = [ [ 1..3 ], [ 4..6 ], [ 7..9 ] ];

plan tests => 7;

my ( $matrix, $constructor, $expected );

$constructor = sub
    {
        Text::Matrix->new(
            rows    => $rows,
            columns => $cols,
            data    => $data,
            );
    };

#
#  1: Basic output.
$matrix = $constructor->();
$expected = <<'EXPECTED';
      Column 1
      | Column 2
      | | Column 3
      | | |
      v v v

Row 1 1 2 3
Row 2 4 5 6
Row 3 7 8 9
EXPECTED
is( $matrix->matrix(), $expected, 'plain output ok' );

#
#  2: Mapped output.
$matrix = $constructor->()->mapper( sub { $_[ 0 ] - 1 } );
$expected = <<'EXPECTED';
      Column 1
      | Column 2
      | | Column 3
      | | |
      v v v

Row 1 0 1 2
Row 2 3 4 5
Row 3 6 7 8
EXPECTED
is( $matrix->matrix(), $expected, 'mapped output ok' );

#
#  3: Multi-character data output.
$matrix = $constructor->()->mapper( sub { $_[ 0 ] + 1 } );
$expected = <<'EXPECTED';
      Column 1
      |  Column 2
      |  |  Column 3
      |  |  |
      v  v  v

Row 1 2  3  4 
Row 2 5  6  7 
Row 3 8  9  10
EXPECTED
is( $matrix->matrix(), $expected, 'multi-character data output ok' );

#
#  4: Wrapped output, unwrapped.
$matrix = $constructor->()->max_width( 20 );
$expected = <<'EXPECTED';
      Column 1
      | Column 2
      | | Column 3
      | | |
      v v v

Row 1 1 2 3
Row 2 4 5 6
Row 3 7 8 9
EXPECTED
is( $matrix->matrix(), $expected, 'unwrapped max-width output ok' );

#
#  5: Wrapped output, wrapped into 2 sections.
$matrix = $constructor->()->max_width( 16 );
$expected = <<'EXPECTED';
      Column 1
      | Column 2
      | |
      v v

Row 1 1 2
Row 2 4 5
Row 3 7 8

      Column 3
      |
      v

Row 1 3
Row 2 6
Row 3 9
EXPECTED
is( $matrix->matrix(), $expected, 'wrapped max-width output ok (1)' );

#
#  6: Wrapped output, wrapped into 3 sections.
$matrix = $constructor->()->max_width( 15 );
$expected = <<'EXPECTED';
      Column 1
      |
      v

Row 1 1
Row 2 4
Row 3 7

      Column 2
      |
      v

Row 1 2
Row 2 5
Row 3 8

      Column 3
      |
      v

Row 1 3
Row 2 6
Row 3 9
EXPECTED
is( $matrix->matrix(), $expected, 'wrapped max-width output ok (2)' );

#
#  7: Wrapped output, unable to meet criteria.
$matrix = $constructor->()->max_width( 13 );
is( $matrix->matrix(), undef, 'undef on too-narrow' );
