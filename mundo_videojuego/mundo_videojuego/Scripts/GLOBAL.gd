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
	"Money": 0
}

# 🔹 Productos cargados en memoria
var products: Array = []

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
