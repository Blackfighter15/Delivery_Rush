extends Node2D  # Cambia Area2D por Node2D

@export var velocity: Vector2 = Vector2.ZERO
@export var gravity_force: float = 700.0

func _physics_process(delta: float) -> void:
	# aplicar gravedad
	velocity.y += gravity_force * delta
	# mover proyectil (usando position del Node2D)
	global_position += velocity * delta

	# eliminar si se va demasiado abajo
	if global_position.y > 2000:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("objetivo"):
		body.queue_free()
		queue_free()
