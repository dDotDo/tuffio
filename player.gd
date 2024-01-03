extends CharacterBody2D

@onready var hurtbox_area = $'Sprite2D/PunchArea'
@onready var akCooldownTimer := $'AK47Timer'
@onready var characterHitbox_area = $'PlayerArea'

const max_speed = 800
const accel = 19000
const friction = 19000

var input = Vector2.ZERO

@export var bullet: PackedScene

var equipment_data = {
	"helmet": null,
	"chest": null,
	"combat": "fist",
}

func _ready():
	print(equipment_data)

func _physics_process(delta):
	player_movement(delta)

func get_input():
	input.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	input.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
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

# Input.is_action_just_pressed("click") FOR SINGLE CLICK AKA PISTOL
# Input.is_mouse_button_pressed(1) FOR HOLD DOWN CLICK AKA AK47

func _process(delta):
	look_at(get_global_mouse_position())
	if Input.is_mouse_button_pressed(1) and equipment_data["combat"] == "autoGun" and akCooldownTimer.is_stopped():
		shoot()
	if Input.is_action_just_pressed("click") and equipment_data["combat"] == "manualGun" and akCooldownTimer.is_stopped():
		shoot()

@onready var akSpriteInstance = $'GunAndWep/AK47_Sprite'

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed and can_attack:
		$PunchTimer.start()
		var random_choice = randf()

		if random_choice < 0.5:
			$AnimationPlayer.play("left_punch")
		else:
			$AnimationPlayer.play("right_punch")

		can_attack = false
	else:
		pass
	
	
	####### THIS IS TEMP - NEED A CLEAN WAY TO equip / hide gun (ak, m9, etc)
	#### FOR FUTURE - LOOP THRU THE CURRENT USER'S ITEMS INSTAED OF ALL ITEMS
	
	if (Input.is_action_pressed("loot")): #temp, soon wil add && for when object is inbound
		# check for overlapping bodies
		# if overlapping bodies belongs to group then pick it up
		var intersecting_bodies: Array = characterHitbox_area.get_overlapping_bodies()
		for body in intersecting_bodies:
			if should_be_lootable(body):
				if "AKSprite" in str(body):
					print("This is an AKSprite")
					body.loot_ak()
					$Sprite2D.hide()
					for child in $GunAndWep.get_children():
						child.hide()
					$GunAndWep/AK47_Sprite.show()
					equipment_data["combat"] = "autoGun"
				if "m9Sprite" in str(body):
					print("this is m9 pistol")
					body.loot_m9()
					$Sprite2D.hide()
					for child in $GunAndWep.get_children():
						child.hide()
					$GunAndWep/m9_Sprite.show()
					equipment_data["combat"] = "manualGun"
		print(equipment_data)
		
	if(Input.is_action_pressed("fist")):
		$Sprite2D.show()
		for child in $GunAndWep.get_children():
			child.hide()
		equipment_data["combat"] = "fist"
		print(equipment_data)

var should_be_lootable_group = ['pickable_loot']
func should_be_lootable(body: Node2D) -> bool:
	for group in should_be_lootable_group:
		if not body.is_in_group(group):
			return false
	#if not body.has_method('take_damage'):
		#return false
	return true
	

func shoot():
	var shot = bullet.instantiate()
	get_parent().add_child(shot)
	shot.shoot(global_position, get_global_mouse_position())
	akCooldownTimer.start()

func _on_punch_timer_timeout():
	$PunchTimer.stop()
	can_attack = true

var attack = 1
func deal_damage():
	var intersecting_bodies: Array = hurtbox_area.get_overlapping_bodies()
	print(intersecting_bodies)
	if equipment_data["combat"] == "fist":
		for body in intersecting_bodies:
			if should_deal_damage(body):
				body.take_damage(attack)


var should_take_damage_groups = ['destroyable-object']
func should_deal_damage(body: Node2D) -> bool:
	for group in should_take_damage_groups:
		if not body.is_in_group(group):
			return false
	if not body.has_method('take_damage'):
		return false
	return true
	

