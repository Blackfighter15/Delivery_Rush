extends Area2D

@export var datos_proyectil: ProductosDatos
var velocity: Vector2 = Vector2.ZERO
var gravity_force: float = 0.0

func _ready():
	if datos_proyectil:
		$Sprite2D.texture = datos_proyectil.textura_sprite
	else:
		print("⚠️ Proyectil sin datos asignados!")


func _physics_process(delta: float) -> void:
	position += velocity * delta
	velocity.y += gravity_force * delta

	if position.y > 2000 or position.x > 4000 or position.x < -4000:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("objetivo") and datos_proyectil:
		body.interactuar_con_producto(datos_proyectil.tipo_comida)
		queue_free()
