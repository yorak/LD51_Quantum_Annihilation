extends Node2D

export var LONG_FLICKERS = 1
export var SHORT_FLICKERS = 8
export var LONG_FLICKER_DURATION = 0.05
export var SHORT_FLICKER_DURATION = 0.01
export var SENSE_RANGE = 300

var circles = load("res://assets/cursor.png")
var posneg = false
var flicker_counter = 0	

var levels = [null, # no level for idx 0
	preload("res://Level1.tscn"),
	preload("res://Level2.tscn"),
	preload("res://Level3.tscn"),
	preload("res://Level4.tscn"),
	#preload("res://Level1.tscn")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(circles)
	if Data.level>len(levels)-1:
		get_tree().change_scene("res://End.tscn")
		return
	
	var barriersNode = levels[Data.level].instance()
	var world_node = get_tree().get_root().get_node("World")
	world_node.add_child(barriersNode)
	
	if barriersNode.get_node("PlayerHere")!=null:
		$Player.position = barriersNode.get_node("PlayerHere").position
	if barriersNode.get_node("EnemyHere")!=null:
		$Monster.position =barriersNode.get_node("EnemyHere").position
	if barriersNode.get_node("FlagHere")!=null:
		$Flag.position = barriersNode.get_node("FlagHere").position
	if barriersNode.get_node("GoalHere")!=null:
		$Goal.position = barriersNode.get_node("GoalHere").position
	
	if not $The10sTimer.is_stopped():
		_on_10sTimer_timeout()
		
	

func toggle_pos_neg(positive):
	$Background.toggle_pos_neg(positive)
	$Player.set_visibility_mode(positive)
	$Monster.set_visibility_mode(not positive)
	
	for child in get_node("Barriers").get_children():
		if "Barrier" in child.name:
			if "Pos" in child.name:
				child.visible = not positive
			elif "Neg" in child.name:
				child.visible = positive
				
func _process(delta):
	var distance = $Monster.position.distance_to($Player.position);
	if distance < SENSE_RANGE:
		var show_streght = log(SENSE_RANGE-distance)/log(SENSE_RANGE)
		if posneg:
			$Monster/Field.visible = true
			$Monster/Field.modulate.a = show_streght
		else:
			$Player/Field.visible = true
			$Player/Field.modulate.a = show_streght
	else:
		if posneg:
			$Monster/Field.visible = false
		else:
			$Player/Field.visible = false
			
		$Player/Field.modulate.a = 1.0
		$Monster/Field.modulate.a = 1.0
	
func _on_10sTimer_timeout():
	$TimeLeftDisplay.reset()
	posneg = not posneg
	flicker_counter = LONG_FLICKERS*2 + SHORT_FLICKERS*2
	toggle_pos_neg(posneg)
	if LONG_FLICKERS>0:
		$FlickerTimer.wait_time = LONG_FLICKER_DURATION
	elif SHORT_FLICKERS>0:
		$FlickerTimer.wait_time = SHORT_FLICKER_DURATION
	$FlickerTimer.start()

func _on_FlickerTimer_timeout():
	flicker_counter = flicker_counter-1
	
	var cur_state = posneg
	if flicker_counter%2:
		cur_state = not posneg
	toggle_pos_neg(cur_state)
	
	if flicker_counter-LONG_FLICKERS*2>SHORT_FLICKERS*2:
		$FlickerTimer.wait_time = LONG_FLICKER_DURATION
	else:
		$FlickerTimer.wait_time = SHORT_FLICKER_DURATION
	if  flicker_counter>0:
		$FlickerTimer.start()


func _on_flag_touch(body):
	var flag = $Flag
	if body==$Player:
		self.remove_child(flag)
		body.add_child(flag)
		flag.position = Vector2(20,0)
		# cannot be picked up
		flag.disconnect("body_entered", self, "_on_flag_touch")
		flag.get_node("Sound").play()
		
		


func _on_check_for_win(body):
	for child in body.get_children():
		if "Flag" in child.name and not $Annihilation.playing:
			Data.level+=1
			$Annihilation.show()
			$Annihilation.position = child.position
			$Annihilation.play("default")
			

func _on_HideButton_toggled(button_pressed):
	if not button_pressed:
		$The10sTimer.stop()
		$Player/Core.show()
		$Monster/Core.show()
		$Player/Field.show()
		$Monster/Field.show()
		for child in $Barriers.get_children():
			if "Barrier" in child.name:
				child.show()
	else:
		_on_10sTimer_timeout()
		$The10sTimer.start()

func _on_annihilation_finished():
	get_tree().reload_current_scene()
	
