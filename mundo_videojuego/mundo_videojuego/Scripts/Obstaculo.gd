extends Area2D

@export var speed: float = 200.0

func _ready():
	# Evita conectar varias veces el mismo signal
	var call = Callable(self, "_on_body_entered")
	if not is_connected("body_entered", call):
		connect("body_entered", call)

func _process(delta):
	position.x -= speed * delta
	if position.x < -100:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("💥 Colisión detectada con el jugador")
		body.take_damage(1)
		body.slow_down(100, 3)
		queue_free()  # opcional: eliminar obstáculo
