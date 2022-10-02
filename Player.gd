extends KinematicBody2D

export var MOVEMENT_ACC = 500.0
export var FRICTION = 20.0
export var MOUSE_MOVEMENT_RANGE = 0.2
export var CAPTURED_FLAG_SPEED = 5.0

var velocity := Vector2()
var fully_visible = true

func set_visibility_mode(visible):
	fully_visible = visible
	$Core.visible = fully_visible
	$Field.visible = fully_visible
	
func animate_flicker():
	var rsz = randf()/2.0+0.75
	$Core.scale = Vector2(rsz,rsz)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	animate_flicker()
		
	velocity = max(0,velocity.length()-FRICTION*delta)*velocity.normalized()
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		var vec_towards_player = (self.position - get_global_mouse_position()).normalized()
		var dist_towards_player = self.position.distance_to(get_global_mouse_position())
		#print("mouse push ", min(MOVEMENT_ACC,dist_towards_player/MOUSE_MOVEMENT_RANGE))
		velocity += vec_towards_player*-min(MOVEMENT_ACC,dist_towards_player/MOUSE_MOVEMENT_RANGE)*delta
		
	#var pressed = false
	if Input.is_action_pressed("left"):
		velocity += Vector2.LEFT * MOVEMENT_ACC * delta;
		#if not pressed: $Skin.play("left")
		#pressed = true
	if Input.is_action_pressed("right"):
		velocity += Vector2.RIGHT * MOVEMENT_ACC * delta;
		#if not pressed: $Skin.play("right")
		#pressed = true
	if Input.is_action_pressed("down"):
		velocity += Vector2.DOWN * MOVEMENT_ACC * delta;
		#$Skin.play("down")
		#pressed = true
	if Input.is_action_pressed("up"):
		velocity += Vector2.UP * MOVEMENT_ACC * delta;
		#if not pressed: $Skin.play("up")
		#pressed = true
	
	var flag = get_node("Flag")
	if flag:
		flag.position = flag.position.rotated(delta*CAPTURED_FLAG_SPEED)
		
	var prior_velocity = velocity
	velocity = move_and_slide(velocity)
	for i in get_slide_count():
		var collision := get_slide_collision(i)
		var body := collision.collider
		if body.name == "Monster" and not $"../Annihilation".playing:
			$"../Annihilation".show()
			$"../Annihilation".position = collision.position
			$"../Annihilation".play("default")
			$"../Annihilation/Sound".play()
		
		var particles = $"../PlayerBarrierCollisionParticles"
		if "Barrier" in body.name and prior_velocity.length()>0.1 and not particles.emitting:
			particles.restart()
			particles.modulate = body.get_node("ColorRect").color.lightened(0.2)
			particles.position = collision.position
			particles.rotation = prior_velocity.bounce(collision.normal).angle()
			particles.emitting = true
			
			$Bounce.volume_db = -30+min(30, prior_velocity.length()/10)
			$Bounce.play()
			
			$"../Monster".player_seen_at(collision.position)
			#Vector2(cos(body.global_rotation), sin(body.global_rotation))
			



