extends Node2D
## Minijuego "Dynamite" (extra del Equipo Dynamite, no hace parte de la rúbrica).
## Arrastra la bomba hacia atrás para apuntar y suelta para lanzarla. Al primer
## choque explota y empuja las cajas cercanas. R reinicia la escena.

const FUERZA := 9.0  # px/s de lanzamiento por cada píxel de arrastre
const ARRASTRE_MAX := 110.0  # con este tope la bomba nunca llega a tocar el piso
const RADIO_EXPLOSION := 230.0
const IMPULSO_EXPLOSION := 1100.0
const BOMBAS := 3
const HORQUILLA := Vector2(20, 2)  # puntas del lanzador respecto a la bomba
const COLOR_GOMA := Color("2e1b0a")

## Bomba del lanzador: está congelada y sin colisión; solo sirve para apuntar.
## Cada tiro lanza una copia suya con la física activa.
@onready var bomba: RigidBody2D = $Bomba
@onready var explosion: CPUParticles2D = $Explosion
@onready var humo: CPUParticles2D = $Humo
@onready var destello: Sprite2D = $Destello
@onready var camara: Camera2D = $Camera2D
@onready var marcador: Label = $UI/Marcador
@onready var mensaje: Label = $UI/Mensaje
@onready var final: Label = $UI/Final
@onready var iconos_bomba: HBoxContainer = $UI/Bombas

var _origen: Vector2
var _apuntando := false
var _arrastre := Vector2.ZERO
var _en_vuelo := false
var _terminado := false
var _restantes := BOMBAS
var _proyectil: RigidBody2D
var _inicio_cajas := {}
var _derribadas := {}


func _ready() -> void:
	_origen = bomba.position
	for caja in get_tree().get_nodes_in_group("cajas"):
		_inicio_cajas[caja] = caja.position


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()
	elif _en_vuelo or _restantes == 0 or _terminado:
		return
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var raton: Vector2 = make_input_local(event).position
		if event.pressed and raton.distance_to(_origen) < 70.0:
			_apuntando = true
			_arrastre = Vector2.ZERO
		elif not event.pressed and _apuntando:
			_apuntando = false
			lanzar(_arrastre * FUERZA)
	elif event is InputEventMouseMotion and _apuntando:
		# Arrastre: del ratón hacia el punto de partida, con tope.
		_arrastre = (_origen - make_input_local(event).position).limit_length(ARRASTRE_MAX)
		bomba.position = _origen - _arrastre
		queue_redraw()


func _process(_delta: float) -> void:
	var derribadas := cajas_derribadas()
	marcador.text = "Cajas  %d / %d" % [derribadas, _inicio_cajas.size()]
	for i in iconos_bomba.get_child_count():
		iconos_bomba.get_child(i).modulate.a = 1.0 if i < _restantes else 0.2
	if _terminado:
		return
	if derribadas == _inicio_cajas.size():
		_mostrar_final("¡DEMOLICIÓN TOTAL!", Color("ffd23f"))
	elif _restantes == 0 and not _en_vuelo:
		_mostrar_final("SIN BOMBAS", Color("ff8a5c"))


func _physics_process(_delta: float) -> void:
	# Una bomba que sale de la pantalla sin tocar nada también termina el tiro.
	if is_instance_valid(_proyectil):
		var p := _proyectil.position
		if p.y > 760.0 or p.x > 1300.0 or p.x < -150.0:
			_terminar_tiro()


func _draw() -> void:
	# Gomas del lanzador: rectas en reposo, tensas hasta la bomba al apuntar.
	var izquierda := _origen + Vector2(-HORQUILLA.x, HORQUILLA.y)
	var derecha := _origen + HORQUILLA
	if not _apuntando:
		draw_line(izquierda, derecha, COLOR_GOMA, 4.0)
		return
	draw_line(izquierda, bomba.position, COLOR_GOMA, 5.0)
	draw_line(derecha, bomba.position, COLOR_GOMA, 5.0)
	var gravedad := Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
	var velocidad := _arrastre * FUERZA
	for i in range(1, 30):
		var t := i * 0.06
		var punto := bomba.position + velocidad * t + 0.5 * gravedad * t * t
		draw_circle(punto, 6.0 - i * 0.14, Color(1.0, 0.9, 0.45, 1.0 - i / 32.0))


## Una caja cuenta como derribada cuando se aleja de donde empezó, y ya no
## deja de contar aunque luego ruede de vuelta.
func cajas_derribadas() -> int:
	for caja: RigidBody2D in _inicio_cajas:
		if caja.position.distance_to(_inicio_cajas[caja]) > 40.0:
			_derribadas[caja] = true
	return _derribadas.size()


func lanzar(velocidad: Vector2) -> void:
	queue_redraw()
	if velocidad.length() < 90.0:  # clic sin arrastrar: no cuenta como tiro
		bomba.position = _origen
		return
	_en_vuelo = true
	_restantes -= 1
	_proyectil = bomba.duplicate()
	_proyectil.freeze = false
	_proyectil.linear_velocity = velocidad
	_proyectil.get_node("CollisionShape2D").disabled = false
	_proyectil.body_entered.connect(_on_proyectil_body_entered)
	add_child(_proyectil)
	bomba.visible = false
	mensaje.visible = false


func _on_proyectil_body_entered(_cuerpo: Node) -> void:
	if not is_instance_valid(_proyectil):
		return
	var centro := _proyectil.global_position
	for caja: RigidBody2D in _inicio_cajas:
		var distancia := caja.global_position - centro
		var fuerza := 1.0 - distancia.length() / RADIO_EXPLOSION
		if fuerza > 0.0:
			caja.apply_central_impulse((distancia.normalized() + Vector2.UP * 0.4) * IMPULSO_EXPLOSION * fuerza)
			caja.apply_torque_impulse(randf_range(-4000.0, 4000.0) * fuerza)
	_efecto_explosion(centro)
	_terminar_tiro()


## Parte visual de la explosión: destello, chispas, humo y temblor de cámara.
func _efecto_explosion(centro: Vector2) -> void:
	explosion.global_position = centro
	explosion.restart()
	humo.global_position = centro
	humo.restart()
	destello.global_position = centro
	destello.scale = Vector2(0.4, 0.4)
	destello.modulate.a = 1.0
	destello.visible = true
	var brillo := create_tween().set_parallel()
	brillo.tween_property(destello, "scale", Vector2(3.6, 3.6), 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	brillo.tween_property(destello, "modulate:a", 0.0, 0.35)
	var sacudida := create_tween()
	for i in 6:
		sacudida.tween_property(camara, "offset", Vector2(randf_range(-12, 12), randf_range(-12, 12)), 0.04)
	sacudida.tween_property(camara, "offset", Vector2.ZERO, 0.04)


func _terminar_tiro() -> void:
	_proyectil.queue_free()
	_proyectil = null
	await get_tree().create_timer(1.6).timeout
	_en_vuelo = false
	if _restantes > 0 and cajas_derribadas() < _inicio_cajas.size():
		bomba.position = _origen
		bomba.visible = true


func _mostrar_final(texto: String, color: Color) -> void:
	_terminado = true
	final.text = texto + "\nPulsa R para jugar otra vez"
	final.add_theme_color_override("font_color", color)
	final.visible = true
	final.scale = Vector2(0.4, 0.4)
	create_tween().tween_property(final, "scale", Vector2.ONE, 0.45).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
