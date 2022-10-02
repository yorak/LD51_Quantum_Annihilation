extends Area2D

export var ROTATION_SPEED = 4.0
export var FLICKER_STR = 0.5

func animate_flicker():
	var rsz = (randf()-0.5)*FLICKER_STR+1.0
	$Sprite.scale = Vector2(rsz,rsz)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	animate_flicker()
	var sprite_idx = 0
	for s in get_children():
		if s is Sprite:
			sprite_idx+=1
			s.rotation += delta*ROTATION_SPEED*sprite_idx
	
