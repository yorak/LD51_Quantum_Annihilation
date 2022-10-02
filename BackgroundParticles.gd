extends Sprite

export var ATTENUATION := 0.1
export var MASS := 0.1
export var DAMPENING := 4.0

var project_resolution := Vector2()
var movement_allowance := Vector2()
var velocity := Vector2()

func _ready():
	project_resolution = Vector2(
		ProjectSettings.get_setting("display/window/size/width"),
		ProjectSettings.get_setting("display/window/size/height") )
		
	movement_allowance = Vector2(
		self.texture.get_width()-project_resolution.x,
		self.texture.get_height()-project_resolution.y)


func _process(delta):
	velocity = max(0,velocity.length()-DAMPENING*delta)*velocity.normalized()
	
	var player_pos = $"/root/World/Player".position
	var rel_pos = Vector2(
		2*(player_pos.x-project_resolution.x/2)/project_resolution.x,
		2*(player_pos.y-project_resolution.y/2)/project_resolution.y)
	var target_position = Vector2(
		movement_allowance.x*rel_pos.x*(1.0-ATTENUATION),
		movement_allowance.y*rel_pos.y*(1.0-ATTENUATION))
	velocity += (self.position-target_position)*-MASS*(1.0-ATTENUATION)
	self.position += velocity*delta
