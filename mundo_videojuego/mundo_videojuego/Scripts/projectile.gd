extends Area2D

@export var speed: float = 150.0
var direction := Vector2.ZERO

func _process(delta):
	position += direction * speed * delta

	if position.x < -50 or position.x > 900 or position.y < -50 or position.y > 650:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("💥 Impacto en el jugador")
		body.take_damage(1)
		body.slow_down(100, 3)
		queue_free()
