extends Node2D

@export var speed: float = 150.0
@export var projectile_scene: PackedScene
@export var fire_delay: float = 1.5  # segundos antes de disparar

var target: Node2D = null
var timer: float = 0.0
var fired := false
var leaving := false

func _ready():
	target = get_tree().get_first_node_in_group("player")

	# --- obtener carriles desde Global ---
	var lanes = Global.game_data["lanes"]

	# --- escoger un carril distinto al del jugador ---
	if target:
		var available = lanes.filter(func(y): return abs(y - target.position.y) > 5)
		
		# si no queda ningún carril disponible, usa uno random
		if available.is_empty():
			position.y = lanes.pick_random()
		else:
			position.y = available.pick_random()
	else:
		position.y = lanes.pick_random()

	# posición inicial fuera de pantalla
	position.x = -50


func _process(delta):
	if not target:
		return

	if not fired:
		# --- mover suavemente hacia el jugador ---
		position.x = lerp(position.x, target.position.x, 2.0 * delta)

		# --- disparar tras delay ---
		timer += delta
		if timer >= fire_delay:
			_fire_projectile()
			fired = true
			leaving = true
	elif leaving:
		# --- salir de pantalla ---
		position.x += speed * delta
		if position.x > 1000:
			queue_free()


# -----------------------------
# 🚀 Disparo del enemigo
# -----------------------------
func _fire_projectile():
	if not projectile_scene:
		return

	var proj = projectile_scene.instantiate()
	get_parent().add_child(proj)

	proj.position = position
	proj.direction = (target.position - position).normalized()


# -----------------------------
# 💥 Colisión con el jugador
# -----------------------------
func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(1)

	if body.has_method("slow_down"):
		body.slow_down(100, 3)
		
	queue_free()
