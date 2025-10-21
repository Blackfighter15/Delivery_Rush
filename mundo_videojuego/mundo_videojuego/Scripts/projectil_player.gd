extends Area2D

@export var velocity: Vector2 = Vector2.ZERO
@export var gravity_force: float = 0.0

# Almacena solo la referencia al jugador y el producto que lleva.
var player_node: CharacterBody2D = null
var product_to_deliver: String = "" 

# 🎯 FUNCIÓN DE INICIALIZACIÓN: Recibe los datos del Player
func initialize(player: CharacterBody2D, selected_product: String):
	player_node = player
	product_to_deliver = selected_product
	# Ya no necesita el _ready() que daba error, porque se inicializa aquí.
	
func _ready():
	pass

func _physics_process(delta: float) -> void:
	position += velocity * delta

	# Aplicar gravedad
	velocity.y += gravity_force * delta

	# eliminar si se sale de la pantalla
	if position.y > 2000 or position.x > 4000 or position.x < -4000:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("objetivo"):
		
		# 🎯 Reportar la entrega al Player
		if is_instance_valid(player_node):
			player_node.track_delivery_progress(product_to_deliver)
		else:
			push_error("❌ Proyectil no inicializado. No se pudo registrar la entrega.")
			
		body.queue_free() # Destruye el objetivo
		queue_free()    # Destruye el proyectil
