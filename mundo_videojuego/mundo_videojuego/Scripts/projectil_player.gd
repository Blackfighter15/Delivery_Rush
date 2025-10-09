extends Area2D

@export var velocity: Vector2 = Vector2.ZERO
@export var gravity_force: float = 0.0  # sin curva

func _physics_process(delta: float) -> void:
	position += velocity * delta

	# eliminar si se sale de la pantalla
	if position.y > 2000 or position.x > 4000 or position.x < -4000:
		queue_free()

func _on_body_entered(body: Node) -> void:
	print("Colisión con: ", body.name) # debug

	if body.is_in_group("objetivo"):
		body.queue_free()  # destruye la ventana
		queue_free()       # destruye el proyectil
