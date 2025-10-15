extends CharacterBody2D


var pause_screen: Control

@export var lanes = [245, 275, 310, 340]  
var current_lane := 1  

@export var speed: float = 200.0
var normal_speed: float = 200.0
@export var Aumento: float = 0
@export var Hearts: int = 5

@export var projectile_scene: PackedScene
@export var shoot_force: float = 700.0  # más rápido y más lejos

func _ready():
	# Cargar e instanciar la escena del menú pausa
	var pause_scene = preload("res://Escenas/menu_esc.tscn")
	pause_screen = pause_scene.instantiate()
	
	# Usar call_deferred para añadir el hijo de forma segura
	get_tree().root.call_deferred("add_child", pause_screen)
	
	# Esperar un frame para que el nodo esté completamente listo
	await get_tree().process_frame
	pause_screen.visible = false  # Ocultar al inicio

func _physics_process(_delta: float) -> void:
	var input = Vector2.ZERO
	
	# movimiento horizontal
	if Input.is_action_pressed("ui_left"):
		input.x -= 1
	if Input.is_action_pressed("ui_right"):
		input.x += 1
	
	velocity.x = input.x * speed + Aumento
	move_and_slide()
	
	# cambio de carril
	if Input.is_action_just_pressed("ui_up") and current_lane > 0:
		current_lane -= 1
	elif Input.is_action_just_pressed("ui_down") and current_lane < lanes.size() - 1:
		current_lane += 1
	
	# mover suavemente al carril
	position.y = lerp(position.y, float(lanes[current_lane]), 0.1)

	# disparo
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot() -> void:
	if projectile_scene == null:
		return
	
	var projectile = projectile_scene.instantiate()
	projectile.position = global_position

	# dirección hacia el mouse
	var dir = (get_global_mouse_position() - global_position).normalized()
	projectile.velocity = dir * shoot_force
	
	get_parent().add_child(projectile)
	
	#Funcion para cuando el player recibe daño
func take_damage(amount: int):
	Hearts -= amount
	if Hearts <= 0:
		Hearts = 0  # Asegurar que no sea negativo
		game_over()
		
func game_over():
	get_tree().paused = true
	# Cargar y mostrar la escena de game over
	var game_over_scene = preload("res://Escenas/game_over.tscn")
	var game_over_instance = game_over_scene.instantiate()
	get_tree().root.add_child(game_over_instance)
	
	#Funcion para el estado de relantizacion del player
func slow_down(amount: float, duration: float): 
	speed = max(speed - amount, 0)
	print("Jugador ralentizado")
	await get_tree().create_timer(duration).timeout
	speed = normal_speed
	print("Velocidad restaurada")
	
	
func _input(event):
	if event.is_action_pressed("Pause"): # Asegúrate de tener esta acción en el Input Map
		toggle_pause()

func toggle_pause():
	var should_pause = !get_tree().paused
	get_tree().paused = should_pause
	
	if pause_screen:
		pause_screen.visible = should_pause
