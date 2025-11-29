extends Node2D

@export var obstacle_scene: PackedScene
@export var enemy_scene: PackedScene
@export var lanes: Array = [245, 275, 310, 340]
@export var spawn_interval: float = 2.0
@export var enemy_chance: float = 0.4   # 0 = nunca enemigo, 1 = siempre enemigo

# 🔹 Recursos de obstáculos
@export var obstacle_resources: Array[Obstaculosdatos] = []

var timer := 0.0

func _ready():
	randomize()  # importante para que randi() sea aleatorio

func _process(delta):
	timer += delta
	if timer >= spawn_interval:
		timer = 0
		spawn_entity()

func spawn_entity():
	var entity

	if randf() < enemy_chance and enemy_scene:
		entity = enemy_scene.instantiate()
		entity.position = Vector2(-50, lanes.pick_random())
		print("👾 Enemigo creado")
	else:
		if obstacle_scene:
			entity = obstacle_scene.instantiate()
			entity.position = Vector2(800, lanes.pick_random())
			print("🟥 Obstáculo creado")

			# Asignar recurso aleatorio
			if obstacle_resources.size() > 0:
				var recurso = obstacle_resources[randi() % obstacle_resources.size()]
				entity.set_data(recurso)

	if entity:
		add_child(entity)
