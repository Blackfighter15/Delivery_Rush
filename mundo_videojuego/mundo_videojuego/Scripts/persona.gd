extends StaticBody2D

class_name Cliente 
@export var datos_cliente: ClienteDatos
var atendido: bool = false 

# --- NUEVO: Variable para guardar qué marker estamos ocupando ---
var current_marker = null 
# ---------------------------------------------------------------

func _ready():
	if datos_cliente:
		$Sprite2D.texture = datos_cliente.textura_sprite
		print("¡Ha llegado un cliente!")
		print("Tipo de pedido: ", datos_cliente.tipo_comida)

# --- NUEVO: Esta función se ejecuta automáticamente al morir el nodo ---
func _exit_tree():
	# Si tenemos un marker asignado y este sigue existiendo en el juego...
	if current_marker and is_instance_valid(current_marker):
		# ...le decimos que ya no está ocupado.
		current_marker.set_meta("ocupado", false)
# ---------------------------------------------------------------------

func interactuar_con_producto(producto_entregado: String):
	if atendido:
		return

	var pedido_cliente: String = datos_cliente.tipo_comida
	var producto_jugador: String = producto_entregado
	
	var PENALIZACION: int = 5 

	if pedido_cliente == producto_jugador:
		print("✅ ¡Entrega exitosa! Cliente satisfecho con:", pedido_cliente)
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("track_delivery_progress"):
			player.track_delivery_progress(pedido_cliente, 1)
	else:
		print("❌ ¡Entrega incorrecta! Pedido: %s, Recibido: %s" % [pedido_cliente, producto_jugador])
		print("💸 ¡Penalización! Se restan %d por error." % PENALIZACION)
		Global.set_money(Global.game_data["Money"] - PENALIZACION)
		Global.save_game() 
	
	atendido = true
	# Al llamar a queue_free(), Godot disparará automáticamente _exit_tree() arriba
	queue_free()
