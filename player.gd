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
	"display": "fist",
	"inventory": {
		"combat": "fist",
		"gun": [null, null],
	}
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
	if Input.is_mouse_button_pressed(1) and equipment_data["display"] == "gun" and equipment_data["inventory"]["gun"][1] == "autoGun" and akCooldownTimer.is_stopped():
		shoot()
	if Input.is_action_just_pressed("click") and equipment_data["display"] == "gun" and equipment_data["inventory"]["gun"][1] == "manualGun" and akCooldownTimer.is_stopped():
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
	
	if (Input.is_action_pressed("loot")): #temp, soon wil add && for when object is inbound
		var intersecting_bodies: Array = characterHitbox_area.get_overlapping_bodies()
		for body in intersecting_bodies:
			if should_be_lootable(body):
				if "AKSprite" in str(body):
					loot_weapon(body, "AKSprite", "loot_ak", "AK47_Sprite", "autoGun", "ak")
					
				if "m9Sprite" in str(body):
					loot_weapon(body, "m9Sprite", "loot_m9", "m9_Sprite", "manualGun", "m9")
		print(equipment_data)
		
	if(Input.is_action_pressed("fist")):
		$Sprite2D.show()
		for child in $GunAndWep.get_children():
			child.hide()
		equipment_data["display"] = "fist"
		print(equipment_data)
		
	if (Input.is_action_pressed("2")): #show gun in inventory
		print("tryna find gun")
		if equipment_data["inventory"]["gun"][0] != null:
			equip_wep(equipment_data["inventory"]["gun"][0], "autoGun", "ak")

func equip_wep(weapon_sprite: String, gunAutoOrMan: String, inventory_name: String):
	$Sprite2D.hide()
	for child in $GunAndWep.get_children():
		child.hide()
	$GunAndWep.get_node(weapon_sprite).show()
	equipment_data["display"] = "gun"
	equipment_data["inventory"]["gun"][1] = gunAutoOrMan
	equipment_data["inventory"]["gun"][0] = weapon_sprite
	

func loot_weapon(body, weapon_type: String, loot_method: String, weapon_sprite: String, gunAutoOrMan: String, inventory_name: String) -> void:
	print("This is a", weapon_type)
	body.call(loot_method)
	$Sprite2D.hide()

	# Hide all children in GunAndWep
	for child in $GunAndWep.get_children():
		child.hide()

	# Show the specific weapon sprite
	$GunAndWep.get_node(weapon_sprite).show()

	# Update equipment_data
	equipment_data["display"] = "gun"
	equipment_data["inventory"]["gun"][1] = gunAutoOrMan
	equipment_data["inventory"]["gun"][0] = weapon_sprite


var should_be_lootable_group = ['pickable_loot']
func should_be_lootable(body: Node2D) -> bool:
	for group in should_be_lootable_group:
		if not body.is_in_group(group):
			return false
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
	if equipment_data["display"] == "fist":
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
	

