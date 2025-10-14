extends Control

@export var Mundo_juego: String = "res://Escenas/main_escene.tscn"

@onready var boton_comenzar: TextureButton = $botoncomenzar
@onready var boton_configurar: TextureButton = $botonconfigurar
@onready var boton_Salir: TextureButton = $botonsalir
func _ready() -> void:
	if boton_comenzar:
		boton_comenzar.pressed.connect(_on_botoncomenzar_pressed)
	elif boton_configurar:
		pass
	else: 
		boton_Salir.pressed.connect(_on_botonsalir_pressed)
	
func _on_botoncomenzar_pressed() -> void:
	cambiar_escena_juego()

func cambiar_escena_juego():
		get_tree().change_scene_to_file(Mundo_juego)

func _on_botonsalir_pressed() -> void:
	get_tree().quit()
