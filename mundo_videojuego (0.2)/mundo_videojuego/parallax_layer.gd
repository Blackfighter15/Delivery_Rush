extends ParallaxLayer

@export var city_speed: float = 80.0

func _process(delta):
	motion_offset.x -= city_speed * delta
