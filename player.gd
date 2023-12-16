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
	pass

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed and can_attack:

		$PunchTimer.start()

		var random_choice = randf()

		if random_choice < 0.5:
			$AnimationPlayer.play("left_punch")
			#$Sprite2D.animation = "punch_left"
		else:
			$AnimationPlayer.play("right_punch")
			#$AnimationPlayer.animation = "punch_right"

		#$Sprite2D.play()
		can_attack = false
	else:
		pass
		#$Sprite2D.animation= "default"
		#$Sprite2D.stop()
		

func _on_punch_timer_timeout():
	$PunchTimer.stop()
	can_attack = true


func _on_punch_area_area_entered(area):
	if area.is_in_group("hurtbox"):
		print("hit!")
		area.take_damage()

