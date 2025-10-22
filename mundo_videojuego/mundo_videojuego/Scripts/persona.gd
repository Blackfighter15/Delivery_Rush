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

	# 1. Obtener los tipos de comida
	var pedido_cliente: String = datos_cliente.tipo_comida
	var producto_jugador: String = producto_entregado # Producto recibido del proyectil

	# 2. Comparación
	if pedido_cliente == producto_jugador:
		# Entrega correcta
		print("✅ ¡Entrega exitosa! Cliente satisfecho con:", pedido_cliente)
		
	else:
		# Entrega incorrecta
		print("❌ ¡Entrega incorrecta! Pedido: %s, Recibido: %s" % [pedido_cliente, producto_jugador])
	
	atendido = true # Marcar como atendido
	queue_free()    # El cliente desaparece
