extends CanvasLayer # O CanvasLayer, lo que sea tu nodo raíz

func _ready():
	# Asegúrate de que este menú funcione aunque el juego esté pausado
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_salir_pressed() -> void:
	queue_free()
