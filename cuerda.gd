extends Line2D
## Dibuja la varilla del péndulo entre el ancla y el peso. Es solo visual:
## la unión física la hace el PinJoint2D.

@export var desde: NodePath
@export var hasta: NodePath

@onready var _a: Node2D = get_node(desde)
@onready var _b: Node2D = get_node(hasta)


func _process(_delta: float) -> void:
	points = PackedVector2Array([_a.global_position, _b.global_position])
