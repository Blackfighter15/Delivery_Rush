extends Control



func _ready() -> void:
	   # Configurar procesamiento cuando está en pausa
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	# Ocultar al inicio
	visible = false

func _on_resume_pressed() -> void:
	get_tree().paused = false
	self.visible = false


func _on_salir_pressed() -> void:
	 # IMPORTANTE: Reanudar el juego antes de cambiar de escena
	get_tree().paused = false
	
	# Cargar y cambiar a la escena del menú principal
	var main_menu_scene = load("res://Escenas/MenuInicio.tscn") 
	get_tree().change_scene_to_packed(main_menu_scene)
