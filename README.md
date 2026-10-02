# Fisica_GrupoDynamite: laboratorio de física en Godot

Taller de la Unidad 2, Diseño Multimedia y Videojuegos. Godot 4.5.

## Integrantes

- Erick Ocampo
- Andrés Rodríguez
- Daniel Arteaga

## Escenas por nivel

- Niveles 1 a 3: laboratorio.tscn (reto del nivel 3: bola.gd)
- Nivel 4: nivel4.tscn
- Nivel 5: nivel5.tscn (reto del nivel 5: zona_antigravedad.gd)
- Bonus 3D: lab3d.tscn

## Extra: minijuego "Dynamite"

- juego.tscn (script: juego.gd), fuera de la rúbrica.
- Arrastra la bomba hacia atrás para apuntar y suelta para lanzarla; al primer
  choque explota y empuja las cajas cercanas. Hay 3 bombas para derribar las
  9 cajas. La tecla R reinicia.

## Aspecto visual

Los nodos que pide la guía conservan su nombre, su tipo y sus valores. Para
mejorar el aspecto se agregaron elementos que no participan en la física:

- Carpeta arte/: texturas de las cajas (caja.svg), de la bola y el peso
  (bola.svg, que se tiñe con Modulate), la cuadrícula de fondo y el arte del
  minijuego. Las cajas y la bola usan estas texturas en lugar de icon.svg,
  con la misma escala de la guía.
- Nodos decorativos: Fondo (cuadrícula de 64 px, el lado de una caja), HUD
  (título de cada nivel), Borde (línea superior del piso) y Cuerda (varilla
  visible del péndulo, dibujada por cuerda.gd).
- En lab3d.tscn: un WorldEnvironment con cielo y materiales en el piso y el
  cubo.

## Cómo abrirlo

Descarga el repositorio, abre Godot 4.5 y en el Project Manager pulsa Import
sobre el archivo project.godot. Cada escena se ejecuta con F6.
