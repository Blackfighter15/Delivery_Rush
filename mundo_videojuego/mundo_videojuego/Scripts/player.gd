extends CharacterBody2D

var pause_screen: Control

@export var lanes = [245, 275, 310, 340]
var current_lane := 1

# Delivery y Misión
var products = ["Pizza","Hamburguesa","Pollo_frito","sushi","comida_china"]
var objetivos_entrega: Dictionary = {}
const MIN_AMOUNT: int = 1
const MAX_AMOUNT: int = 1

# 📦 Lógica de SELECCIÓN de Producto (¡Añadidas!)
var current_product_index: int = 0
var selected_product_name: String = "Pizza" # Inicializa con el primer producto

@export var speed: float = 200.0
var normal_speed: float = 200.0
@export var Aumento: float = 0
@export var Hearts: int = 5

@export var projectile_scene: PackedScene
@export var shoot_force: float = 700.0

func _ready():
	# ... (código de pausa existente)
	var pause_scene = preload("res://Escenas/menu_esc.tscn")
	pause_screen = pause_scene.instantiate()
	get_tree().root.call_deferred("add_child", pause_screen)
	await get_tree().process_frame
	pause_screen.visible = false
	
	# Inicialización de la selección de producto (si la lista no está vacía)
	if not products.is_empty():
		selected_product_name = products[current_product_index]
		
	# Genera los objetivos del jugador
	generate_new_delivery_goal()

func _physics_process(_delta: float) -> void:
	var input = Vector2.ZERO
	
	# ... (código de movimiento existente)
	if Input.is_action_pressed("ui_left"):
		input.x -= 1
	if Input.is_action_pressed("ui_right"):
		input.x += 1
	
	velocity.x = input.x * speed + Aumento
	move_and_slide()
	
	if Input.is_action_just_pressed("ui_up") and current_lane > 0:
		current_lane -= 1
	elif Input.is_action_just_pressed("ui_down") and current_lane < lanes.size() - 1:
		current_lane += 1
	
	position.y = lerp(position.y, float(lanes[current_lane]), 0.1)

	# disparo
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot() -> void:
	if projectile_scene == null:
		return
	
	var projectile = projectile_scene.instantiate()
	projectile.position = global_position

	var dir = (get_global_mouse_position() - global_position).normalized()
	projectile.velocity = dir * shoot_force
	
	# 🎯 CORRECCIÓN: selected_product_name ahora existe y se envía
	if projectile.has_method("initialize"):
		projectile.initialize(self, selected_product_name)
	
	get_parent().add_child(projectile)

# --------------------------------------------------------------------------
# LÓGICA DE INPUT, SELECCIÓN Y MISIÓN
# --------------------------------------------------------------------------

func _input(event):
	if event.is_action_pressed("Pause"): 
		toggle_pause()
		
	if products.is_empty(): return
		
	# 🎯 SOLO ESCUCHAMOS LA ACCIÓN DE AVANCE
	if Input.is_action_just_pressed("change_product"):
		change_product_selection() 
	


func change_product_selection() -> void:
	var total_products = products.size()
	
	if total_products == 0: 
		return
		
	# Calcular el nuevo índice: avanzar 1 y aplicar el módulo.
	# Si current_product_index es 4 y total_products es 5, (4 + 1) % 5 = 0 (vuelve al inicio)
	current_product_index = (current_product_index + 1) % total_products
		
	selected_product_name = products[current_product_index]
	print("Producto seleccionado: ", selected_product_name)
	# Aquí iría la llamada a tu HUD para mostrar el producto activo

func generate_new_delivery_goal() -> void:
	objetivos_entrega.clear()

	for product_name in products:
		var random_amount: int = randi_range(MIN_AMOUNT, MAX_AMOUNT)
		objetivos_entrega[product_name] = random_amount

	print("--- Nuevo Objetivo de Entrega Generado ---")
	for product in objetivos_entrega.keys():
		print("Entregar %d de %s" % [objetivos_entrega[product], product])
	print("------------------------------------------")
	# Aquí iría la llamada a tu HUD para actualizar los objetivos

func track_delivery_progress(product_name: String, amount: int = 1) -> void:
	if product_name in objetivos_entrega:
		objetivos_entrega[product_name] = max(0, objetivos_entrega[product_name] - amount)
		print("Entregado %d de %s. Quedan %d." % [amount, product_name, objetivos_entrega[product_name]])
		
		check_for_mission_completion()

func check_for_mission_completion() -> void:
	var all_goals_met = true
	for amount_needed in objetivos_entrega.values():
		if amount_needed > 0:
			all_goals_met = false
			break
	
	if all_goals_met:
		print("🎉 ¡MISIÓN DE ENTREGA COMPLETADA CON ÉXITO! 🎉")
		# Por simplicidad, iniciamos una nueva misión.
		get_tree().paused = true
		
# --------------------------------------------------------------------------
# OTRAS FUNCIONES (código existente)
# --------------------------------------------------------------------------

func take_damage(amount: int):
	Hearts -= amount
	if Hearts <= 0:
		Hearts = 0
		game_over()
		
func game_over():
	get_tree().paused = true
	var game_over_scene = preload("res://Escenas/game_over.tscn")
	var game_over_instance = game_over_scene.instantiate()
	get_tree().root.add_child(game_over_instance)
	
func slow_down(amount: float, duration: float):
	speed = max(speed - amount, 0)
	print("Jugador ralentizado")
	await get_tree().create_timer(duration).timeout
	speed = normal_speed
	print("Velocidad restaurada")
	
func toggle_pause():
	var should_pause = !get_tree().paused
	get_tree().paused = should_pause
	if pause_screen:
		pause_screen.visible = should_pause
