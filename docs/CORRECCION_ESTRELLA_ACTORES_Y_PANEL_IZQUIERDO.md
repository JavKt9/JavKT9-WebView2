# Corrección estrella de Actores y ancho del panel izquierdo

**11/10/2026.** El usuario aportó un vídeo de 21,7 segundos en el que se observa que al hacer clic en la estrella de Actores se ilumina toda la fila de azul. También informó que, al abrir maximizado por primera vez, el panel izquierdo ocupa demasiado ancho; la memoria de los paneles desplegables sí funciona y debe conservarse.

## Causa en código

En `GCPanel.pm`, la columna «★» del `Gtk3::TreeView` era la última columna y **se estiraba hasta ocupar el ancho libre de la lista**, por lo que un clic lejos del glifo podía tratarse como clic en la estrella. La selección visual de fila también podía permanecer activa.

En `GCMainWindow.pm`, `$self->{pane}->pack1($self->{listPane},1,0)` configuraba el panel izquierdo con `resize=1`: al maximizar, la lista crecía con la ventana.

## Parche experimental reversible

Archivo local: `JAVkt9_RC1_Correccion_Estrella_Actores_Panel_Izquierdo.zip` (49.793 bytes; SHA-256 `505cc2f3108558968dae3310e173880ce053a4c4192446df49cebe72e81348cf`).

- `GCPanel.pm`: fija la columna de estrella a 36 px, impide que se expanda, añade una columna vacía flexible para absorber el ancho sobrante y deselecciona la fila al pulsar la estrella.
- `GCMainWindow.pm`: cambia el primer panel a `resize=0` y respeta el ancho guardado hasta 440 px; si no hay preferencia o el valor guardado es excesivo, comienza en 320 px.
- El ZIP incluye `APLICAR_CORRECCION.cmd`, `RESTAURAR_CORRECCION.cmd`, PowerShell, manifiesto SHA-256 y ambos fuentes Perl completos.
- Solo se aplica a `%LOCALAPPDATA%\Programs\JAVkt9-081-RC1-Fuentes-Prueba`; los scripts verifican hashes y guardan copias `.antes_estrella_lateral`.
- **No se cambia** WebView2, Bridge, el ejecutable, biblioteca de películas, ficha compacta ni estado persistente de expanders.

Hashes de archivos:

| Archivo | Antes | Después |
| --- | --- | --- |
| `GCPanel.pm` | `f0c8bc7e403ec3a5b2f0e8fd49c2670fa8bab3e04be432c8e439fd49dc56b569` | `10a48bf8eb76d91de2d1f4c2c096bdc3fb46cc51af3910c30215eb72470825c9` |
| `GCMainWindow.pm` | `56650768b2ce5cc3eb2a76d00fb14ca523062a63ae739e170629dda00644369b` | `802b4098de3a97eea389eedf65fb13126803a7a422fc48ee07437c6d3b99326e` |

**Verificado:** ZIP CRC correcto y hashes de fuentes y manifiesto consistentes. **No verificado aún:** comportamiento visual GTK3 Windows. El entorno de compilación Linux no tiene el módulo Perl `Gtk3`, así que no se afirma que haya pasado una prueba de ejecución GTK3. La RC1 original y `main` permanecen intactos.
