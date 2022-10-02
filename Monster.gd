extends KinematicBody2D

export var CHASE_MAX_SPEED := 400.0
export var CHASE_ACC := 25.0
export var CHASE_RANGE := 300.0
export var FRICTION := 20.0

var velocity = Vector2()
var fully_visible = true

var player_seen_at = null

func set_visibility_mode(visible):
	fully_visible = visible
	$Core.visible = fully_visible
	$Field.visible = fully_visible
	
func animate_flicker():
	var rsz = randf()/2.0+0.75;
	$Core.scale = Vector2(rsz,rsz)

func accel_towards(this_position, delta, chase_range):
	var distance = self.position.distance_to(this_position);
	var angle = self.position.angle_to_point(this_position)
	if velocity.length()<CHASE_MAX_SPEED:
		var attraction = max(1.0, min(0.1, log(chase_range-distance)/log(chase_range)))
		velocity += Vector2(cos(angle), sin(angle))*\
			(-CHASE_MAX_SPEED*delta*attraction)
			
func _physics_process(delta):
	animate_flicker()
	velocity = max(0,velocity.length()-FRICTION*delta)*velocity.normalized()
	
	var distance = self.position.distance_to($"../Player".position)
	if distance < CHASE_RANGE:
		if distance>10:
			accel_towards($"../Player".position, delta, CHASE_RANGE)
	elif player_seen_at!=null:
		# Closer on the screen, more aggressive is the movement
		accel_towards( player_seen_at, delta, 
			Vector2.ZERO.distance_to(get_viewport().size) )
		
	var prior_velocity = velocity
	velocity = move_and_slide(velocity)
	for i in get_slide_count():
		var collision := get_slide_collision(i)
		var body := collision.collider
		
		if body.name == "Player" and not $"../Annihilation".playing:
			$"../Annihilation".show()
			$"../Annihilation".position = collision.position
			$"../Annihilation".play("default")
		
		var particles = $"../MonsterBarrierCollisionParticles"
		if "Barrier" in body.name and prior_velocity.length()>0.1 and not particles.emitting:
			particles.restart()
			particles.modulate = body.get_node("ColorRect").color.lightened(0.2)
			particles.position = collision.position
			
			particles.rotation = prior_velocity.bounce(collision.normal).angle()
			particles.emitting = true
			
			$Bounce.volume_db = -30+min(30, prior_velocity.length()/10)
			$Bounce.play()
			

func player_seen_at(position):
	player_seen_at = position
	$PlayerSeenTimer.start()


func _on_lost_player_timeout():
	player_seen_at = null
