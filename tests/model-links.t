use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../app/lib/gcstar";
use Test::More;
use GCJavModelLinks qw(is_model_links_list normalize_model_url link_color_for_background);

ok(is_model_links_list('modelLinks', 'Enlaces de modelos', 1), 'lista española de modelos');
ok(is_model_links_list('modelLinks', 'Model links', 1), 'lista inglesa de modelos');
ok(is_model_links_list('other', 'Enlaces de modelos', 1), 'etiqueta visible');
ok(!is_model_links_list('actors', 'Cast', 1), 'no cambia elenco');
ok(!is_model_links_list('models', 'Enlaces de modelos', 2), 'no cambia tablas de dos columnas');
is(normalize_model_url('https://www.javlibrary.com/en/vl_star.php?s=pzfa'),
   'https://www.javlibrary.com/en/vl_star.php?s=pzfa', 'enlace HTTPS completo');
is(normalize_model_url(' http://example.com/?id=1&lang=es '),
   'http://example.com/?id=1&lang=es', 'enlaces con parametros');
ok(!defined(normalize_model_url('javascript:alert(1)')), 'bloquea javascript');
ok(!defined(normalize_model_url('file:///c:/Users')), 'bloquea archivo');
ok(!defined(normalize_model_url('not a link')), 'bloquea texto');
ok(!defined(normalize_model_url('https://example.com/ bad')), 'bloquea espacios internos');
is(link_color_for_background('#FFFFFF'), '#155DB7', 'enlace azul en tema claro');
is(link_color_for_background('#261B2B'), '#99D9FF', 'enlace azul claro en tema oscuro');
is(link_color_for_background(''), '#99D9FF', 'color de respaldo');
done_testing;
