extends CharacterBody2D

@export var lanes = [245, 275, 310, 340]  
var current_lane := 1  

@export var speed: float = 200.0
@export var Aumento: float = 0

@export var projectile_scene: PackedScene
@export var shoot_force: float = 700.0  # más rápido y más lejos

func _physics_process(_delta: float) -> void:
	var input = Vector2.ZERO
	
	# movimiento horizontal
	if Input.is_action_pressed("ui_left"):
		input.x -= 1
	if Input.is_action_pressed("ui_right"):
		input.x += 1
	
	velocity.x = input.x * speed + Aumento
	move_and_slide()
	
	# cambio de carril
	if Input.is_action_just_pressed("ui_up") and current_lane > 0:
		current_lane -= 1
	elif Input.is_action_just_pressed("ui_down") and current_lane < lanes.size() - 1:
		current_lane += 1
	
	# mover suavemente al carril
	position.y = lerp(position.y, float(lanes[current_lane]), 0.1)

	# disparo
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot() -> void:
	if projectile_scene == null:
		return
	
	var projectile = projectile_scene.instantiate()
	projectile.position = global_position

	# dirección hacia el mouse
	var dir = (get_global_mouse_position() - global_position).normalized()
	projectile.velocity = dir * shoot_force
	
	get_parent().add_child(projectile)
