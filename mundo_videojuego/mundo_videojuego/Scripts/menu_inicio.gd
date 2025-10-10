extends Control

@export var escena_destino: String = "res://Escenas/inicio_presionado.tscn"
@onready var boton: TextureButton = $TextureButton  

func _ready():
	if boton:
		boton.pressed.connect(_on_boton_presionado)
	else:
		print("Error: No se encontró el nodo TextureButton")

func _on_boton_presionado():
	cambiar_escena()

func cambiar_escena():
	get_tree().change_scene_to_file(escena_destino)
