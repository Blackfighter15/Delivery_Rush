extends Area2D

@export var velocity: Vector2 = Vector2.ZERO
@export var gravity_force: float = 0.0  # sin curva

func _ready():
	pass

func _physics_process(delta: float) -> void:
	position += velocity * delta

	# Aplicar gravedad si es necesario
	velocity.y += gravity_force * delta

	# eliminar si se sale de la pantalla
	if position.y > 2000 or position.x > 4000 or position.x < -4000:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("objetivo"):
		print("¡Le diste a una persona!")
		body.queue_free()
		queue_free()

		# Buscar el nodo que maneja el nivel
		var nivel = get_tree().get_first_node_in_group("nivel")
		if nivel:
			nivel.registrar_entrega()
		else:
			print("⚠️ No se encontró el nodo del nivel.")
