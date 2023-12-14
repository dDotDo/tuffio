extends Area2D

@export var speed = 400
@onready var screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 2
	if Input.is_action_pressed("move_left"):
		velocity.x -= 2
	if Input.is_action_pressed("move_down"):
		velocity.y += 2
	if Input.is_action_pressed("move_up"):
		velocity.y -= 2

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
