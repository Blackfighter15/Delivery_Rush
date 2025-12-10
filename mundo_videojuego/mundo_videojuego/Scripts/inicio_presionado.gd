extends Control

@export var Mundo_juego: String = "res://Escenas/main_escene.tscn"

@onready var boton_comenzar: TextureButton = $botoncomenzar
@onready var boton_configurar: TextureButton = $botonconfigurar
@onready var boton_Salir: TextureButton = $botonsalir
@onready var Opciones: Panel = $Panel
@onready var PantallaCompletaE: Label = $Panel/botonPantalla/PantallCompleta
@onready var ModoVentana: Label = $Panel/botonPantalla/ModoVentana
var PantallaCompleta = true

func _ready() -> void:
	boton_comenzar.visible=true
	boton_Salir.visible=true
	boton_configurar.visible=true
	Opciones.visible=false
	
	actualizar_labels_pantalla()
	
func _on_botoncomenzar_pressed() -> void:
	cambiar_escena_juego()

func cambiar_escena_juego():
		get_tree().change_scene_to_file(Mundo_juego)

func _on_botonsalir_pressed() -> void:
	get_tree().quit()


func _on_botonconfigurar_pressed() -> void:
	boton_comenzar.visible=false
	boton_Salir.visible=false
	boton_configurar.visible=false
	Opciones.visible=true
	


func _on_boton_volver_pressed() -> void:
	_ready()


func _on_boton_pantalla_pressed() -> void:
	if PantallaCompleta == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		PantallaCompleta=false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		PantallaCompleta=true
		
	actualizar_labels_pantalla()
		
func actualizar_labels_pantalla():
	# Si PantallaCompleta es TRUE, significa que estamos en FullScreen, 
	# y mostramos el label que indica que estamos en ese modo.
	if PantallaCompleta == true:
		PantallaCompletaE.visible = true 
		ModoVentana.visible = false
	# Si PantallaCompleta es FALSE, significa que estamos en Modo Ventana
	else:
		PantallaCompletaE.visible = false
		ModoVentana.visible = true


func _on_boton_controles_pressed() -> void:
	var pantalla_controles = load("res://Escenas/controles.tscn").instantiate()
	get_tree().root.add_child(pantalla_controles)
