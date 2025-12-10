extends CanvasLayer

# --- CONFIGURACIÓN ---
# Ruta a tu escena de inicio (Menú Principal)
@export_file("*.tscn") var start_scene_path: String = "res://Escenas/MenuInicio.tscn"

# Ruta exacta de tu archivo de guardado.
# Si guardas en una carpeta, ajusta esto (ej: "user://saves/partida1.save")
const SAVE_PATH: String = "user://save_game.dat" 

# Evita que se active el cambio de escena múltiples veces si el jugador machaca botones
var _is_transitioning: bool = false

func _ready():
	# Opcional: Asegurarse de que el ratón sea visible si estaba oculto durante el juego
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	# Si ya estamos cambiando de escena, ignorar nuevos inputs
	if _is_transitioning:
		return

	# Detectar "Cualquier Botón" (Teclado, Botón de Mando o Clic de Ratón)
	if (event is InputEventKey and event.pressed) or \
	   (event is InputEventJoypadButton and event.pressed) or \
	   (event is InputEventMouseButton and event.pressed):
		
		_handle_victory_reset()

func _handle_victory_reset():
	_is_transitioning = true
	print("Victoria aceptada. Borrando progreso y volviendo al inicio...")
	
	# 1. Borrar el guardado
	_delete_save_data()
	
	# 2. Cambiar a la escena de inicio
	if start_scene_path:
		get_tree().change_scene_to_file(start_scene_path)
	else:
		printerr("¡Error! No has asignado la 'start_scene_path' en el Inspector.")

func _delete_save_data():
	# --- MÉTODOS PARA GODOT 4.X ---
	
	# OPCIÓN A: Si tu guardado es un solo archivo (lo más común)
	if FileAccess.file_exists(SAVE_PATH):
		var error = DirAccess.remove_absolute(SAVE_PATH)
		if error == OK:
			print("Archivo de guardado eliminado correctamente: ", SAVE_PATH)
		else:
			printerr("Error al intentar borrar el archivo: ", error)
	else:
		print("No se encontró archivo de guardado para borrar (¿Tal vez ya estaba borrado?).")
