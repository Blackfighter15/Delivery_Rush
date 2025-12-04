extends CharacterBody2D

# ---------------- VARIABLES ----------------
var pause_screen: Control
var objetivos_entrega: Dictionary = {}  # Misiones actuales
var character_width = 16.0
var slow_timer: Timer = null
var is_slowed: bool = false

@export var projectile_scene: PackedScene
@export var shoot_force: float = 700.0
var can_shoot: bool = true
@export var shoot_delay: float = 0.8

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

# ---------------- READY ----------------
func _ready():
	# 🔹 Cargar datos del Global
	Global.load_game()
	Global.reiniciar_datos_sesion()
	Global.reset_hearts()
	Global.reset_speed()
	
	# ---------------- PANTALLA DE PAUSA ----------------
	var pause_scene = preload("res://Escenas/menu_esc.tscn")
	pause_screen = pause_scene.instantiate()
	get_tree().root.call_deferred("add_child", pause_screen)
	await get_tree().process_frame
	pause_screen.visible = false

	# ---------------- PRODUCTO SELECCIONADO ----------------
	var index = Global.game_data.current_product_index
	if Global.products.size() > 0:
		Global.game_data.selected_product_name = Global.products[index].tipo_comida

	generate_new_delivery_goal()
	call_deferred("update_hud_goals")
	
	# ---------------- CURSOR PERSONALIZADO ----------------
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var crosshair = Sprite2D.new()
	crosshair.texture = preload("res://Assets/assets visuales/crosshair.png")
	crosshair.name = "crosshair"
	crosshair.scale = Vector2(0.5, 0.5)
	crosshair.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(crosshair)

	# Carril inicial
	position.y = Global.game_data.lanes[Global.game_data.current_lane]

	set_process(true)

# ---------------- PHYSICS PROCESS ----------------
func _physics_process(_delta: float) -> void:
	var input = Vector2.ZERO
	var lanes = Global.game_data.lanes
	var current_lane = Global.game_data.current_lane

	# Movimiento horizontal
	if Input.is_action_pressed("Izquierda"):
		input.x -= 1
	if Input.is_action_pressed("Derecha"):
		input.x += 1

	velocity.x = input.x * Global.game_data.speed
	move_and_slide()

	# --- RESTRICCIÓN DE PANTALLA (EJE X) ---
	var viewport_width = get_viewport_rect().size.x
	var left_limit = character_width / 2.0
	var right_limit = 540
	position.x = clamp(position.x, left_limit, right_limit)

	# Cambio de carril
	if Input.is_action_just_pressed("Arriba") and current_lane > 0:
		current_lane -= 1
	elif Input.is_action_just_pressed("Abajo") and current_lane < lanes.size() - 1:
		current_lane += 1

	Global.game_data.current_lane = current_lane
	position.y = lerp(position.y, float(lanes[current_lane]), 0.1)

	# Disparo con delay
	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot()
		can_shoot = false
		await get_tree().create_timer(shoot_delay).timeout
		can_shoot = true

# ---------------- DISPARO ----------------
func shoot() -> void:
	if projectile_scene == null or Global.products.size() == 0:
		return

	# 🔊 SONIDO DE DISPARO
	if audio_stream_player_2d:
		audio_stream_player_2d.play()

	var projectile = projectile_scene.instantiate()
	projectile.position = global_position

	# Producto actual
	var index = Global.game_data.current_product_index
	var projectile_resource = Global.products[index]

	# Dirección
	var dir = (get_global_mouse_position() - global_position).normalized()
	projectile.velocity = dir * shoot_force

	# Datos para el proyectil
	projectile.datos_proyectil = projectile_resource

	get_parent().add_child(projectile)

# ---------------- INPUT ----------------
func _input(event):
	if event.is_action_pressed("Pause"):
		toggle_pause()

	if Global.products.size() == 0:
		return

	if Input.is_action_just_pressed("change_product"):
		change_product_selection()

# ---------------- CAMBIO DE PRODUCTO ----------------
func change_product_selection() -> void:
	var size = Global.products.size()
	if size == 0:
		return

	var index = Global.game_data.current_product_index
	index = (Global.game_data.current_product_index + 1) % Global.products.size()
	Global.set_current_product_index(index)

	Global.game_data.selected_product_name = Global.products[index].tipo_comida
	print("Producto seleccionado: ", Global.game_data.selected_product_name)

	Global.save_game()

	var hud = get_tree().get_root().find_child("HUD", true, false)
	
	if hud and hud.has_method("UpdateSelectedProductByIndex"):
		hud.UpdateSelectedProductByIndex(index)
	else:
		print("Error: No se encontró el HUD o falta la función UpdateSelectedProductByIndex")

# ---------------- MISIÓN ----------------
func generate_new_delivery_goal() -> void:
	var MIN_AMOUNT = Global.game_data.MIN_AMOUNT
	var MAX_AMOUNT = Global.game_data.MAX_AMOUNT

	objetivos_entrega.clear()
	for product in Global.products:
		var amount = randi_range(MIN_AMOUNT, MAX_AMOUNT)
		objetivos_entrega[product.tipo_comida] = amount
		
	Global.actualizar_objetivos(objetivos_entrega)
	print("--- Nuevo Objetivo generado ---")
	for p in objetivos_entrega.keys():
		print("Entregar %d de %s" % [objetivos_entrega[p], p])

func track_delivery_progress(product_name: String, amount: int = 1) -> void:
	if product_name in objetivos_entrega:
		objetivos_entrega[product_name] = max(0, objetivos_entrega[product_name] - amount)
		print("Entregado %d de %s. Quedan %d." % [amount, product_name, objetivos_entrega[product_name]])
		Global.descontar_objetivo(product_name)
		update_hud_goals()
		check_for_mission_completion()

		Global.set_money(Global.game_data["Money"] + (amount * 10))
		Global.save_game()

func update_hud_goals():
	var hud_node = get_tree().current_scene.get_node_or_null("HUD")

	if hud_node and hud_node.has_method("update_delivery_goals"):
		hud_node.update_delivery_goals(objetivos_entrega, Global.products)
	else:
		print("ADVERTENCIA: HUD no encontrado o falta método update_delivery_goals.")

func check_for_mission_completion() -> void:
	var all_done = true
	for v in objetivos_entrega.values():
		if v > 0:
			all_done = false
			break

	if all_done:
		print("🎉 ¡MISIÓN COMPLETADA! 🎉")
		Global.save_game()
		var victory = preload("res://Escenas/Pantalla_Victoria.tscn").instantiate()
		get_tree().root.add_child(victory)
		get_tree().paused = true

# ---------------- DAÑO / GAME OVER ----------------
func take_damage(amount: int):
	Global.set_hearts(max(Global.game_data["Hearts"] - amount, 0))
	print("Vidas restantes: ", Global.game_data.Hearts)
	Global.save_game()
	if Global.game_data.Hearts <= 0:
		game_over()

func game_over():
	Global.save_game()
	get_tree().paused = true
	var go_scene = preload("res://Escenas/game_over.tscn").instantiate()
	get_tree().root.add_child(go_scene)

# ---------------- RALENTIZACIÓN ----------------
func slow_down(amount: float, duration: float):
	var base_speed = Global.game_data["Base_Speed"]

	if not is_slowed:
		Global.game_data["speed"] = max(base_speed - amount, 0)
		is_slowed = true
		print("Jugador ralentizado a: ", Global.game_data["speed"])

	if slow_timer == null:
		slow_timer = Timer.new()
		add_child(slow_timer)
		slow_timer.one_shot = true
		slow_timer.timeout.connect(func():
			Global.game_data["speed"] = base_speed
			is_slowed = false
			print("Velocidad restaurada a: ", base_speed)
		)

	slow_timer.stop()
	slow_timer.start(duration)

# ---------------- PAUSA ----------------
func toggle_pause():
	var pause_state = !get_tree().paused
	get_tree().paused = pause_state
	if pause_screen:
		pause_screen.visible = pause_state
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if pause_state else Input.MOUSE_MODE_HIDDEN)

# ---------------- CURSOR ----------------
func _process(_delta: float):
	var cross = get_node_or_null("crosshair")
	if cross:
		cross.global_position = get_global_mouse_position()
