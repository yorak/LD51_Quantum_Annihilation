extends Node2D


export(Color, RGB) var POSITIVE_MODULATE_COLOR
export(Color, RGB) var NEGATIVE_MODULATE_COLOR
export var MODULATE_PER_LAYER = 0.2
export var MODULATE_PARTICLE_LAYER = 0.1

func toggle_pos_neg(positive):
	var layer = 0
	for child in get_children():
		if child is Sprite:
			if "Balls" in child.name:
				if positive:
					child.modulate = POSITIVE_MODULATE_COLOR.darkened(
						layer*MODULATE_PER_LAYER)
				else:
					child.modulate = NEGATIVE_MODULATE_COLOR.darkened(
						layer*MODULATE_PER_LAYER)
			if "Particles" in child.name:
				if positive:
					child.modulate = POSITIVE_MODULATE_COLOR.lightened(
						layer*MODULATE_PARTICLE_LAYER)
				else:
					child.modulate = NEGATIVE_MODULATE_COLOR.lightened(
						layer*MODULATE_PARTICLE_LAYER)
			layer+=1
