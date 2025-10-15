extends Control

@onready var boton_reintentar = $CanvasLayer/TextureButton
@onready var boton_regresar = $CanvasLayer/TextureButton2

func _ready():
	# Configurar este nodo para que funcione aunque el árbol esté pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# También configurar los botones por si acaso
	boton_reintentar.process_mode = Node.PROCESS_MODE_ALWAYS
	boton_regresar.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_texture_button_2_pressed() -> void:
	# Reanudar el juego antes de cambiar de escena
	get_tree().paused = false
	var main_menu_scene = load("res://Escenas/inicio_presionado.tscn")
	get_tree().change_scene_to_packed(main_menu_scene)
	# Eliminar la pantalla de game over
	queue_free()

func _on_texture_button_pressed() -> void:
	# Reanudar el juego antes de recargar
	get_tree().paused = false
	get_tree().reload_current_scene()
	# Eliminar la pantalla de game over
	queue_free()
