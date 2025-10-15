extends Control

@export var Mundo_juego: String = "res://Escenas/main_escene.tscn"

@onready var boton_comenzar: TextureButton = $botoncomenzar
@onready var boton_configurar: TextureButton = $botonconfigurar
@onready var boton_Salir: TextureButton = $botonsalir
func _ready() -> void:
	pass
	
func _on_botoncomenzar_pressed() -> void:
	cambiar_escena_juego()

func cambiar_escena_juego():
		get_tree().change_scene_to_file(Mundo_juego)

func _on_botonsalir_pressed() -> void:
	get_tree().quit()


func _on_botonconfigurar_pressed() -> void:
	pass # Replace with function body.
