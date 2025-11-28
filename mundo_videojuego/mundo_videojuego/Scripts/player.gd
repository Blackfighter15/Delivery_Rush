extends CharacterBody2D

var pause_screen: Control
# Esta variable se mantiene local, ya que es el objetivo actual de la misión y 
# asumimos que las misiones se regeneran en cada carga/inicio.
var objetivos_entrega: Dictionary = {} 

@export var projectile_scene: PackedScene
@export var shoot_force: float = 700.0

# ⏱️ DELAY / COOLDOWN DE DISPARO
var can_shoot: bool = true
@export var shoot_delay: float = 0.8  # 0.2 = 200ms entre disparos (puedes cambiarlo desde el Inspector)

func _ready():
	# ✔ Cargar todos los datos guardados
	Global.load_game()
	# ✔ Después de cargar, restaurar las vidas al máximo
	Global.reset_hearts()
	Global.reset_speed()
	
	# --- Pantalla de pausa ---
	var pause_scene = preload("res://Escenas/menu_esc.tscn")
	pause_screen = pause_scene.instantiate()
	get_tree().root.call_deferred("add_child", pause_screen)
	await get_tree().process_frame
	pause_screen.visible = false

	# --- Producto Seleccionado ---
	var products = Global.game_data.products
	var current_product_index = Global.game_data.current_product_index
	
	if not products.is_empty():
		Global.game_data.selected_product_name = products[current_product_index]

	generate_new_delivery_goal()

# -------------------------
	# 🎯 CURSOR PERSONALIZADO
	# -------------------------
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var crosshair = Sprite2D.new()
	crosshair.texture = preload("res://Assets/assets visuales/crosshair.png")
	crosshair.name = "crosshair"
	crosshair.scale = Vector2(5, 5)
	# Mantenemos la configuración de filtro de la versión HEAD
	crosshair.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(crosshair)

	# Establecer carril inicial (del commit Sistema de guardado)
	position.y = Global.game_data.lanes[Global.game_data.current_lane]

	set_process(true)

func _physics_process(_delta: float) -> void:
	var input = Vector2.ZERO
	var lanes = Global.game_data.lanes
	# Obtener el carril actual del Global
	var current_lane = Global.game_data.current_lane
	
	# Movimiento horizontal (usando la velocidad del Global)
	if Input.is_action_pressed("Izquierda"):
		input.x -= 1
	if Input.is_action_pressed("Derecha"):
		input.x += 1

	velocity.x = input.x * Global.game_data.speed
	move_and_slide()

	# Cambio de carril
	if Input.is_action_just_pressed("Arriba") and current_lane > 0:
		current_lane -= 1
	elif Input.is_action_just_pressed("Abajo") and current_lane < lanes.size() - 1:
		current_lane += 1

	# Actualizar el índice del carril en el diccionario global
	Global.game_data.current_lane = current_lane

	# Mover suavemente al carril
	position.y = lerp(position.y, float(lanes[current_lane]), 0.1)

	# 🔫 DISPARO CON DELAY
	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot()
		can_shoot = false
		await get_tree().create_timer(shoot_delay).timeout
		can_shoot = true

func shoot() -> void:
	if projectile_scene == null:
		return

	var projectile = projectile_scene.instantiate()
	projectile.position = global_position
	
	# Acceder al nombre del producto seleccionado desde el Global
	var selected_product_name = Global.game_data.selected_product_name

	var dir = (get_global_mouse_position() - global_position).normalized()
	projectile.velocity = dir * shoot_force

	# Si el proyectil tiene un script para inicializarse (ej: con el tipo de comida)
	if projectile.has_method("initialize"):
		projectile.initialize(self, selected_product_name)

	get_parent().add_child(projectile)

func _input(event):
	if event.is_action_pressed("Pause"):
		toggle_pause()

	# Usar lista de productos del Global
	if Global.game_data.products.is_empty():
		return

	if Input.is_action_just_pressed("change_product"):
		change_product_selection()

func change_product_selection() -> void:
	# Lógica para actualizar el índice en el Global
	var products = Global.game_data.products
	var total_products = products.size()
	if total_products == 0:
		return

	var current_product_index = Global.game_data.current_product_index
	current_product_index = (current_product_index + 1) % total_products
	
	# Actualizar Global
	Global.game_data.current_product_index = current_product_index
	Global.game_data.selected_product_name = products[current_product_index]
	
	print("Producto seleccionado: ", Global.game_data.selected_product_name)
	# Guardar el cambio del producto seleccionado
	Global.save_game()

func generate_new_delivery_goal() -> void:
	# Usar productos y límites de Global
	var products = Global.game_data.products
	var MIN_AMOUNT = Global.game_data.MIN_AMOUNT
	var MAX_AMOUNT = Global.game_data.MAX_AMOUNT
	
	objetivos_entrega.clear()
	for product_name in products:
		var random_amount: int = randi_range(MIN_AMOUNT, MAX_AMOUNT)
		objetivos_entrega[product_name] = random_amount

	print("--- Nuevo Objetivo de Entrega Generado ---")
	for product in objetivos_entrega.keys():
		print("Entregar %d de %s" % [objetivos_entrega[product], product])
	print("------------------------------------------")

func track_delivery_progress(product_name: String, amount: int = 1) -> void:
	# Esta función se llama (presumiblemente) desde otro nodo 
	# (ej: una casa) cuando se completa una entrega.
	
	if product_name in objetivos_entrega:
		objetivos_entrega[product_name] = max(0, objetivos_entrega[product_name] - amount)
		print("Entregado %d de %s. Quedan %d." % [amount, product_name, objetivos_entrega[product_name]])
		check_for_mission_completion()
		
		# 3. Actualizar Dinero en el Global (ejemplo de recompensa)
		Global.game_data.Money += (amount * 10) # Gana 10 de dinero por entrega
		print("Dinero total: ", Global.game_data.Money)
		
		# Guardar el estado después de ganar dinero
		Global.save_game()

func check_for_mission_completion() -> void:
	var all_goals_met = true
	for amount_needed in objetivos_entrega.values():
		if amount_needed > 0:
			all_goals_met = false
			break

	if all_goals_met:
		print("🎉 ¡MISIÓN DE ENTREGA COMPLETADA CON ÉXITO! 🎉")
		# Guardar el estado final de la misión
		Global.save_game() 
		
		var victory_scene = preload("res://Escenas/Pantalla_Victoria.tscn")
		var victory_instance = victory_scene.instantiate()
		get_tree().root.add_child(victory_instance)
		get_tree().paused = true

# --------------------------------------------------------------------------
# OTRAS FUNCIONES (DAÑO, GAME OVER, PAUSA)
# --------------------------------------------------------------------------

func take_damage(amount: int):
	# 4. Modificar Vidas en el Global
	var current_hearts = Global.game_data.Hearts
	current_hearts -= amount
	
	# Actualizar Global
	Global.game_data.Hearts = max(current_hearts, 0) 
	
	print("Vidas restantes: ", Global.game_data.Hearts)
	
	# Guardar el progreso después de recibir daño
	Global.save_game()

	if Global.game_data.Hearts <= 0:
		game_over()

func game_over():
	# 5. Guardar el estado final antes de la pantalla de Game Over
	Global.save_game()
	
	get_tree().paused = true
	var game_over_scene = preload("res://Escenas/game_over.tscn")
	var game_over_instance = game_over_scene.instantiate()
	get_tree().root.add_child(game_over_instance)

func slow_down(amount: float, duration: float):
	# Usar y modificar la velocidad en el Global
	# Guardamos la velocidad normal actual antes de cambiarla
	var normal_speed = Global.game_data.speed 
	Global.game_data.speed = max(normal_speed - amount, 0)
	
	print("Jugador ralentizado")
	await get_tree().create_timer(duration).timeout
	
	# Restaurar velocidad
	Global.game_data.speed = normal_speed 
	print("Velocidad restaurada")

func toggle_pause():
	var should_pause = !get_tree().paused
	get_tree().paused = should_pause

	if pause_screen:
		pause_screen.visible = should_pause

	if should_pause:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta: float) -> void:
	var crosshair = get_node_or_null("crosshair")
	if crosshair:
		crosshair.global_position = get_global_mouse_position()
