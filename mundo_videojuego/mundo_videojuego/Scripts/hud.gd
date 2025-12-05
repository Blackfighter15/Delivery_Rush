extends Control

# --- REFERENCIAS A NODOS ---
# Ya no referenciamos vida1, vida2... referenciamos EL CONTENEDOR.
@onready var hearts_container =  $Vidas
@onready var dinero_label = $VBoxContainer2/Money
@onready var producto_texture = $Comida
@onready var goals_container = $GoalsContainer


# REFERENCIAS A LA BARRA DE PROGRESO
@onready var survival_container = $SurvivalContainer # El contenedor padre
@onready var survival_bar = $SurvivalContainer/background
@onready var survival_icon = $SurvivalContainer/background/iconplayer

# --- RECURSOS (Arrastra aquí tu imagen de corazón en el Inspector) ---
@export var heart_texture: Texture2D

func _ready() -> void:
	if survival_container:
		survival_container.visible = false
	# Conectar señales globales
	if Global.has_signal("vidas_cambiadas"):
		Global.vidas_cambiadas.connect(Vidas)
	if Global.has_signal("dinero_cambiado"):
		Global.dinero_cambiado.connect(Money)
	if Global.has_signal("producto_cambiado"):
		Global.producto_cambiado.connect(UpdateSelectedProductByIndex)

	# Actualizar HUD al inicio
	Vidas() # Esto ahora generará los corazones
	Money()
	UpdateSelectedProductByIndex(Global.game_data.current_product_index)
	

# 🛠️ Función Vidas() DINÁMICA (Estilo Goals)
func Vidas(nuevas_vidas: int = -1) -> void:
	# 1. Obtener datos
	if nuevas_vidas == -1:
		nuevas_vidas = Global.game_data.get("Hearts", 3)

	# 2. Limpiar el contenedor (igual que haces en goals)
	# Esto borra los corazones viejos antes de dibujar los nuevos
	for child in hearts_container.get_children():
		child.queue_free()

	# 3. Generar los iconos dinámicamente
	# Creamos un TextureRect por cada punto de vida que tengamos
	for i in range(nuevas_vidas):
		var icon = TextureRect.new()
		
		# Configuración visual del icono
		if heart_texture:
			icon.texture = heart_texture
		
		# Opciones de tamaño y estiramiento para que no se vean deformes
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(32, 32) # Ajusta este tamaño a tu gusto (ej. 32x32)
		
		# 4. Añadir al contenedor
		hearts_container.add_child(icon)

func Money(nuevo_dinero: int = -1) -> void:
	if nuevo_dinero == -1:
		nuevo_dinero = Global.game_data["Money"]
	dinero_label.text = str(nuevo_dinero)
	
# ---------------- PRODUCTO SELECCIONADO ----------------
func UpdateSelectedProductByIndex(index: int) -> void:
	if index >= 0 and index < Global.products.size():
		var producto = Global.products[index]
		if producto.textura_sprite:
			producto_texture.texture = producto.textura_sprite

# ---------------- 💡 ACTUALIZACIÓN DE OBJETIVOS (Tu código original) ----------------
func update_delivery_goals(objetivos_actuales: Dictionary, all_products: Array) -> void:
	if goals_container == null: return

	for child in goals_container.get_children():
		child.queue_free()

	var product_map: Dictionary = {}
	for product_res in all_products:
		product_map[product_res.tipo_comida] = product_res

	for product_name in objetivos_actuales.keys():
		var amount_needed: int = objetivos_actuales[product_name]
		if amount_needed <= 0: continue

		var goal_row = HBoxContainer.new()
		
		var texture_rect = TextureRect.new()
		if product_map.has(product_name):
			var product_info = product_map[product_name]
			if product_info.textura_sprite:
				texture_rect.texture = product_info.textura_sprite
				texture_rect.custom_minimum_size = Vector2(32, 32)
				texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		goal_row.add_child(texture_rect)

		var goal_label = Label.new()
		goal_label.text = " x %d" % [amount_needed]
		goal_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		goal_row.add_child(goal_label)

		goals_container.add_child(goal_row)


func update_survival_status(time_left: float, total_time: float, mostrar: bool = true) -> void:
	if survival_container == null: return

	if not mostrar:
		survival_container.visible = false
		return

	survival_container.visible = true
	
	# 2. Actualizar Icono de Jugador (Skin actual)
	# Solo lo asignamos si no tiene textura (para no cargarlo en cada frame)
	if survival_icon.texture == null or survival_icon.texture != Global.get_current_skin_texture():
		survival_icon.texture = Global.get_current_skin_texture()

	# 3. MATEMÁTICAS DE MOVIMIENTO
	# Calculamos cuánto porcentaje del nivel hemos completado (de 0.0 a 1.0)
	# Si queda 45s de 45s -> (1 - 1) = 0 (Inicio)
	# Si queda 0s de 45s -> (1 - 0) = 1 (Final)
	var progress_ratio = 1.0 - (time_left / total_time)
	
	# Obtenemos el ancho disponible para moverse
	# Restamos el ancho del icono para que no se salga de la barra al final
	var bar_width = survival_bar.size.x
	var icon_width = survival_icon.size.x
	var max_travel_dist = bar_width - icon_width
	
	# Movemos el icono
	survival_icon.position.x = max_travel_dist * progress_ratio
