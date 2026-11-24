use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../app/lib/gcstar";
use Test::More;
use GCJavTitleCleanup qw(clean_alternative_title);

is(clean_alternative_title('ACHJ-084', 'ACHJ-084 A Black Daycare'),
   'A Black Daycare', 'elimina el codigo repetido al importar');
is(clean_alternative_title('ACHJ-084', 'ACHJ-084: A Black Daycare'),
   'A Black Daycare', 'acepta separador de dos puntos');
is(clean_alternative_title('ACHJ-084', 'ACHJ-084 - A Black Daycare'),
   'A Black Daycare', 'acepta separador de guion');
is(clean_alternative_title('ACHJ-084', 'achj-084 A Black Daycare'),
   'A Black Daycare', 'no depende de mayusculas');
is(clean_alternative_title('ACHJ-084', 'XYZ-999 Another Movie'),
   'XYZ-999 Another Movie', 'conserva otros identificadores');
is(clean_alternative_title('ACHJ-084', 'ACHJ-084'),
   'ACHJ-084', 'no deja vacio el nombre alternativo');
is(clean_alternative_title('ACHJ-084', 'ACHJ-084A Another Movie'),
   'ACHJ-084A Another Movie', 'no modifica codigos prefijo');
is(clean_alternative_title('ACHJ-084', 'A Black Daycare ACHJ-084'),
   'A Black Daycare ACHJ-084', 'solo elimina codigo al principio');
is(clean_alternative_title('A Black Daycare', 'ACHJ-084 A Black Daycare'),
   'ACHJ-084 A Black Daycare', 'sin codigo principal no hace suposiciones');
is(clean_alternative_title('ACHJ-084', undef), undef, 'admite valores vacios');
is(clean_alternative_title('DANDYA-013', 'DANDYA-013 Ambushing A Beautiful Massage Parlor Girl'),
   'Ambushing A Beautiful Massage Parlor Girl', 'titulo alternativo del ejemplo del usuario');
done_testing;
