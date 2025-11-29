extends Control

@onready var vida1=$"HBoxContainer2/vida 1"
@onready var vida2=$"HBoxContainer2/vida 2"
@onready var vida3= $"HBoxContainer2/vida 3"
@onready var dinero_label = $VBoxContainer2/Money
@onready var producto_texture =$Comida


func _ready() -> void:
	# Conectar señales
	Global.vidas_cambiadas.connect(Vidas)
	Global.dinero_cambiado.connect(Money)
	Global.producto_cambiado.connect(UpdateSelectedProductByIndex)

	# Actualizar HUD al inicio
	Vidas()
	Money()
	UpdateSelectedProductByIndex(Global.game_data.current_product_index)


# Mantenemos el _process(delta) sin cambios...
func _process(delta: float) -> void:
	pass
	
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
