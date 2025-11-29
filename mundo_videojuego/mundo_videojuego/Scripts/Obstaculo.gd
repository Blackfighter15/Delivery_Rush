extends Area2D

@export var data: Obstaculosdatos
@export var speed: float = 200.0

func _ready():
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

	# Si data ya está asignado al instanciar
	if data:
		_set_texture()

func set_data(recurso: Obstaculosdatos) -> void:
	data = recurso
	_set_texture()

func _set_texture():
	if $Sprite2D and data:
		$Sprite2D.texture = data.textura_sprite

func _process(delta):
	position.x -= speed * delta
	if position.x < -100:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("💥 Colisión con jugador")
		body.take_damage(1)
		body.slow_down(100, 3)
		queue_free()
