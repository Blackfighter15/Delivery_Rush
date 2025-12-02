extends StaticBody2D

# Variable para asignar el recurso de datos desde el Inspector
class_name Cliente 
@export var datos_cliente: ClienteDatos
var atendido: bool = false # Para evitar dobles interacciones

func _ready():
	if datos_cliente:
		# 1. Aplicar el Aspecto
		$Sprite2D.texture = datos_cliente.textura_sprite
		
		# 2. Identificar el Tipo (Lógica del Juego)
		print("¡Ha llegado un cliente!")
		print("Tipo de pedido: ", datos_cliente.tipo_comida)
		
func interactuar_con_producto(producto_entregado: String):
	if atendido:
		return

	var pedido_cliente: String = datos_cliente.tipo_comida
	var producto_jugador: String = producto_entregado
	
	# Define la penalización por una entrega incorrecta
	var PENALIZACION: int = 5 
	# Puedes ajustar este valor según la dificultad que desees

	if pedido_cliente == producto_jugador:
		print("✅ ¡Entrega exitosa! Cliente satisfecho con:", pedido_cliente)
		
		# ... (Código de éxito, que llama a track_delivery_progress) ...
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("track_delivery_progress"):
			player.track_delivery_progress(pedido_cliente, 1)
	else:
		print("❌ ¡Entrega incorrecta! Pedido: %s, Recibido: %s" % [pedido_cliente, producto_jugador])
		
		# ⬇️ NUEVA LÓGICA DE PENALIZACIÓN ⬇️
		print("💸 ¡Penalización! Se restan %d por error." % PENALIZACION)
		Global.set_money(Global.game_data["Money"] - PENALIZACION)
		Global.save_game() 
		# ⬆️ FIN DE NUEVA LÓGICA DE PENALIZACIÓN ⬆️
		
	
	atendido = true
	queue_free()
	
