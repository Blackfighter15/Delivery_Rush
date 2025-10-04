extends Node2D

@export var obstacle_scene: PackedScene
@export var enemy_scene: PackedScene   # 👈 nuevo: escena del enemigo
@export var lanes = [245, 275, 310, 340]
@export var spawn_interval: float = 2.0
@export var enemy_chance: float = 0.4   # 👈 probabilidad de que salga enemigo (0.3 = 30%)

var timer := 0.0

func _process(delta):
	timer += delta
	if timer >= spawn_interval:
		timer = 0
		spawn_entity()

func spawn_entity():
	var entity

	if randf() < enemy_chance and enemy_scene:
		entity = enemy_scene.instantiate()
		entity.position = Vector2(-50, lanes.pick_random()) # izquierda
		print("👾 Enemigo creado")
	else:
		entity = obstacle_scene.instantiate()
		entity.position = Vector2(800, lanes.pick_random()) # derecha
		print("🟥 Obstáculo creado")

	add_child(entity)
