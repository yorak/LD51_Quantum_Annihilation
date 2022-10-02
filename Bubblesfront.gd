extends Sprite

export var CIRCLING_SIZE = 10
export var SPEED = 2.0

var project_resolution := Vector2()
var movement_allowance := Vector2()
var velocity := Vector2()
var tick = 0

func _ready():
	project_resolution = Vector2(
		ProjectSettings.get_setting("display/window/size/width"),
		ProjectSettings.get_setting("display/window/size/height") )
		
	movement_allowance = Vector2(
		self.texture.get_width()-project_resolution.x,
		self.texture.get_height()-project_resolution.y)


func _process(delta):
	tick+=delta
	self.position = Vector2( 
		project_resolution.x/2+CIRCLING_SIZE*sin(tick*SPEED),
		project_resolution.y/2+CIRCLING_SIZE*cos(tick*SPEED))
