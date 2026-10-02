extends RigidBody2D

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		apply_central_impulse(Vector2(1500, -1200))
		print("Impulso aplicado a la bola")
