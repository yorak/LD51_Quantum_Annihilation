extends ColorRect

var time_left = 10
var initial_rect_x = self.rect_size.x

func _process(delta):
	time_left-=delta
	rect_size.x = time_left/10.0*initial_rect_x
	
func reset():
	time_left = 10
	$Sound.play()
