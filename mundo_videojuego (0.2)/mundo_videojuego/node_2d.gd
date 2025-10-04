extends Node2D

@export var scroll_speed: float = 120.0
@export var block_width: int = 2000
@onready var blocks = [$"Primer Nivel",$"Primer Nivel2"]  # hijos TileMapLayer

func _process(delta):
	for block in blocks:
		block.position.x -= scroll_speed * delta

		# si el bloque sale por la izquierda
		if block.position.x <= -block_width:
			# encontrar el bloque más adelantado
			var rightmost = blocks[0]
			for b in blocks:
				if b.position.x > rightmost.position.x:
					rightmost = b
			
			# recolocar este bloque justo después del más adelantado
			block.position.x = rightmost.position.x + block_width
