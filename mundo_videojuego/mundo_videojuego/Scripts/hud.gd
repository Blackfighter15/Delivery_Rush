extends Control

@onready var vida1=$"HBoxContainer2/vida 1"
@onready var vida2=$"HBoxContainer2/vida 2"
@onready var vida3= $"HBoxContainer2/vida 3"
@onready var dinero_label = $VBoxContainer2/Money
@onready var producto_texture =$Comida
@onready var goals_container = $GoalsContainer

func _ready() -> void:
# Conectar señales globales para actualizar la UI automáticamente
	if Global.has_signal("vidas_cambiadas"):
		Global.vidas_cambiadas.connect(Vidas)
	if Global.has_signal("dinero_cambiado"):
		Global.dinero_cambiado.connect(Money)
	if Global.has_signal("producto_cambiado"):
		Global.producto_cambiado.connect(UpdateSelectedProductByIndex)

	# Actualizar HUD al inicio con valores actuales
	Vidas()
	Money()
	UpdateSelectedProductByIndex(Global.game_data.current_product_index)
	
# 🛠️ Función Vidas() con la lógica de verificación CORREGIDA
# Usamos asignación directa, que es la forma más limpia.
func Vidas(nuevas_vidas: int = -1) -> void:
	if nuevas_vidas == -1:
		nuevas_vidas = Global.game_data["Hearts"]

	var hearts = nuevas_vidas

	vida1.visible = hearts >= 1
	vida2.visible = hearts >= 2
	vida3.visible = hearts >= 3
	
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



# ---------------- 💡 ACTUALIZACIÓN DE OBJETIVOS DE ENTREGA ----------------
# Esta función DEBE ser llamada desde el script del Player (Player.gd)
# Se llama cuando se genera una misión y cada vez que se entrega algo.
func update_delivery_goals(objetivos_actuales: Dictionary, all_products: Array) -> void:
	
	if goals_container == null:
		print("Error: No se encontró el nodo GoalsContainer en el HUD")
		return

	# 1. Limpiar la lista anterior para evitar duplicados
	for child in goals_container.get_children():
		child.queue_free()

	# 2. Crear un mapa rápido para buscar texturas por nombre de comida
	var product_map: Dictionary = {}
	for product_res in all_products:
		product_map[product_res.tipo_comida] = product_res

	# 3. Generar una fila en el HUD para cada objetivo activo
	for product_name in objetivos_actuales.keys():
		var amount_needed: int = objetivos_actuales[product_name]
		
		# Si la cantidad necesaria es 0 o menor, no mostrarlo (ya se completó)
		if amount_needed <= 0:
			continue

		# Crear un contenedor horizontal para alinear Icono + Texto
		var goal_row = HBoxContainer.new()
		
		# --- A) Icono del Producto ---
		var texture_rect = TextureRect.new()
		if product_map.has(product_name):
			var product_info = product_map[product_name]
			var texture: Texture = product_info.textura_sprite 
			
			if texture != null:
				texture_rect.texture = texture
				# Ajustar tamaño del icono (32x32 píxeles)
				texture_rect.custom_minimum_size = Vector2(32, 32)
				texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		goal_row.add_child(texture_rect)

		# --- B) Texto de Cantidad ---
		var goal_label = Label.new()
		# Muestra "x 3" al lado del icono
		goal_label.text = " x %d" % [amount_needed]
		goal_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		goal_row.add_child(goal_label)

		# Añadir la fila al contenedor vertical principal
		goals_container.add_child(goal_row)
		
	print("HUD: Lista de objetivos actualizada.")
