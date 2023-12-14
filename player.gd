extends CharacterBody2D

const max_speed = 800
const accel = 19000
const friction = 19000

var input = Vector2.ZERO

func _physics_process(delta):
	player_movement(delta)

func get_input():
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return input.normalized()
	
func player_movement(delta):
	input = get_input()
	
	# Check if there is no input
	if input == Vector2.ZERO:
		# Apply friction to gradually slow down the player
		if velocity.length() > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * accel * delta)
		velocity = velocity.limit_length(max_speed)

	move_and_slide()

var can_attack = true

func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_attack:
		$PunchTimer.start()
		# Generate a random number between 0 and 1
		var random_choice = randf()
		print("hi")
		 #Set the animation based on the random number
		if random_choice < 0.5:
			$AnimatedSprite2D.animation = "punch_left"
		else:
			$AnimatedSprite2D.animation = "punch_right"
		#$AnimatedSprite2D.animation = "punch_left"
		$AnimatedSprite2D.play()
		can_attack = false
	else:
		$AnimatedSprite2D.animation= "default"
		$AnimatedSprite2D.stop()



func _on_punch_timer_timeout():
	$PunchTimer.stop()
	print("uh")
	can_attack = true
