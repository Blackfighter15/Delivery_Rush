extends Node

signal vidas_cambiadas(nuevas_vidas)
signal dinero_cambiado(nuevo_dinero)
signal producto_cambiado(nuevo_producto_index)


var save_Path = "user://save_game.dat"

# 🔹 Paths de productos
var PRODUCT_PATHS := [
	"res://Recursos_Productos/Pizza.tres",
	"res://Recursos_Productos/Hamburguesa.tres",
	"res://Recursos_Productos/Comida_China.tres",
	"res://Recursos_Productos/Sushi.tres",
    "res://Recursos_Productos/Pollo_Frito.tres"
]

# 🔹 Diccionario global solo con índices, nombres y datos simples
var game_data : Dictionary = {
	"lanes": [245, 275, 310, 340],
	"current_lane": 1,
	"current_product_index": 0,
	"selected_product_name": "Pizza",
	"MIN_AMOUNT": 1,
	"MAX_AMOUNT": 5,
	"speed": 200.0,
	"Base_Speed": 200.0,
	"Hearts": 3,
	"Max_Hearts": 3,
	"Money": 0,
	"Level":1
}

var LEVEL_CONFIG = {
	1: { 
		"spawn_interval": 2.5, 
		"speed_bonus": 0.0, 
		"enemy_chance": 0.2  # 20% probabilidad de enemigo
	},
	2: { 
		"spawn_interval": 2.5, 
		"speed_bonus": 500.0, 
		"enemy_chance": 0.3 
	},
	3: { 
		"spawn_interval": 1, 
		"speed_bonus": 200.0, 
		"enemy_chance": 0.7
		}
}

# 🔹 Productos cargados en memoria
var products: Array = []
var objetivos_activos: Dictionary = {}

func _ready():
	load_products()

func load_products():
	products.clear()
	for path in PRODUCT_PATHS:
		var res = load(path)  # carga el recurso
		if res != null:
			products.append(res)
		else:
			print("⚠️ Error cargando recurso: ", path)

# ---------------- Funciones de guardado/carga ----------------

func save_game() -> void:
	var data = game_data.duplicate()
	data.erase("Hearts")  # NO guardar vidas
	var file = FileAccess.open(save_Path, FileAccess.WRITE)
	file.store_var(data)
	file = null

func load_game() -> void:
	if FileAccess.file_exists(save_Path):
		var file = FileAccess.open(save_Path, FileAccess.READ)
		game_data = file.get_var()
		file = null
		if !game_data.has("Hearts"):
			game_data["Hearts"] = 3

func reset_hearts():
	set_hearts(game_data["Max_Hearts"])

func reset_speed():
	game_data["speed"] = game_data["Base_Speed"]

func set_hearts(new_value: int):
	var clamped = clamp(new_value, 0, game_data["Max_Hearts"])
	if game_data["Hearts"] != clamped:
		game_data["Hearts"] = clamped
		vidas_cambiadas.emit(clamped)

func set_money(new_value: int):
	var money = max(new_value, 0)
	if game_data["Money"] != money:
		game_data["Money"] = money
		dinero_cambiado.emit(money)
		
func set_current_product_index(new_index: int) -> void:
	if new_index < 0 or new_index >= products.size():
		return

	game_data.current_product_index = new_index
	game_data.selected_product_name = products[new_index].tipo_comida

	# Emitir señal para HUD u otros nodos
	producto_cambiado.emit(new_index)

	save_game()
	
func reiniciar_datos_sesion():
	# Limpiamos los objetivos para que no se mezclen con la partida anterior
	objetivos_activos.clear()
	
	# Reseteamos vidas y velocidad a sus valores base
	reset_hearts()
	reset_speed()
	print("🧹 Datos de sesión limpiados correctamente.")
	
# 1. El Player llama a esto cuando decide la misión
func actualizar_objetivos(nuevos_objetivos: Dictionary):
	objetivos_activos = nuevos_objetivos.duplicate()
	print("📡 Global actualizado con objetivos: ", objetivos_activos)

# 2. El Nivel llama a esto para saber si DEBE generar un cliente
func es_cliente_necesario(tipo_comida: String) -> bool:
	if objetivos_activos.has(tipo_comida):
		return objetivos_activos[tipo_comida] > 0
	return false

# 3. El Player llama a esto cuando entrega algo con éxito
func descontar_objetivo(tipo_comida: String):
	if objetivos_activos.has(tipo_comida):
		objetivos_activos[tipo_comida] -= 1
		# Evitamos números negativos
		if objetivos_activos[tipo_comida] < 0:
			objetivos_activos[tipo_comida] = 0
		print("📉 Restante en Global para ", tipo_comida, ": ", objetivos_activos[tipo_comida])

func get_current_level_config() -> Dictionary:
	var current_lvl = 1
	
	# Si el nivel existe en el diccionario, lo devolvemos
	if LEVEL_CONFIG.has(current_lvl):
		return LEVEL_CONFIG[current_lvl]
	
	# Si el jugador superó el nivel máximo definido (ej: va por nivel 20 y solo definiste 5),
	# devolvemos la configuración del nivel más alto que tengas.
	var max_defined_level = LEVEL_CONFIG.keys().max()
	return LEVEL_CONFIG[max_defined_level]
