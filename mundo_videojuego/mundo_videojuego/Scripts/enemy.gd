extends Node2D

@export var speed: float = 150.0
@export var projectile_scene: PackedScene
@export var fire_delay: float = 1.5  # segundos antes de disparar
@export var lanes = [245, 275, 310, 340]

var target: Node2D = null
var timer: float = 0.0
var fired := false
var leaving := false

func _ready():
	target = get_tree().get_first_node_in_group("player")

	# --- escoger un carril distinto al del jugador ---
	if target:
		var available = lanes.filter(func(y): return abs(y - target.position.y) > 5)
		position.y = available.pick_random()
	else:
		position.y = lanes.pick_random()

	# posición inicial a la izquierda
	position.x = -50

func _process(delta):
	if not target:
		return

	if not fired:
		# --- mover suavemente hacia la X del jugador ---
		position.x = lerp(position.x, target.position.x, 2.0 * delta)

		# --- disparo después de cierto tiempo ---
		timer += delta
		if timer >= fire_delay:
			_fire_projectile()
			fired = true
			leaving = true  # empieza a irse después del disparo
	elif leaving:
		# --- salir de pantalla después de disparar ---
		position.x += speed * delta
		if position.x > 1000:
			queue_free()

# --- función de disparo ---
func _fire_projectile():
	if not projectile_scene:
		return

	var proj = projectile_scene.instantiate()
	get_parent().add_child(proj)
	proj.position = position
	proj.direction = (target.position - position).normalized()
	
func _on_body_entered(body: Node2D) -> void:
	body.take_damage(20.0)
	body.slow_down(100, 3)
