extends Node

var save_Path="user://save_game.dat"

var game_data : Dictionary ={
	"lanes" : [245, 275, 310, 340],
	"current_lane" : 1,
	# Delivery y Misión
	"products" : ["Pizza", "Hamburguesa","comida_china","sushi","Pollo_frito"],
	"MIN_AMOUNT": 1,
	"MAX_AMOUNT": 5,
	# 📦 Lógica de SELECCIÓN de Producto
	"current_product_index": 0,
	"selected_product_name": "Pizza",
	"speed": 200.0,
	"Base_Speed": 200.0,
	"Hearts":5,
	"Max_Hearts": 5,
	"Money":0
}

func save_game() -> void:
	var data_to_save = game_data.duplicate()
	data_to_save.erase("Hearts") # <- NO guardar vidas

	var save_file = FileAccess.open(save_Path,FileAccess.WRITE)
	save_file.store_var(data_to_save)
	save_file = null
	 
func load_game() -> void: 
	if FileAccess.file_exists(save_Path):
		var save_file=FileAccess.open(save_Path,FileAccess.READ)
		
		game_data = save_file.get_var() # cargar variable
		save_file = null #Cerrar archivo
		
func reset_hearts():
	game_data["Hearts"] = game_data["Max_Hearts"]
	
func reset_speed():
	game_data["speed"] = game_data["Base_Speed"]
