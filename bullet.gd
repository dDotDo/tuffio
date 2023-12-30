extends Node2D

var direction := Vector2.ZERO

@export var speed := 1000.0
@onready var hurtbox_area = $'Sprite2D/BulletArea'

func shoot(from: Vector2, to: Vector2):
	global_position = from
	direction = from.direction_to(to)
	rotation = direction.angle()
	$Sprite2D.position.x = 100

func _physics_process(delta):
	position += direction * speed * delta * 2

var attack = 1

var should_take_damage_groups = ['destroyable-object']
func should_deal_damage(body: Node2D) -> bool:
	for group in should_take_damage_groups:
		if not body.is_in_group(group):
			return false
	if not body.has_method('take_damage'):
		return false
	return true


func _on_bullet_area_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	var intersecting_bodies: Array = hurtbox_area.get_overlapping_bodies()
	for object in intersecting_bodies:
		if should_deal_damage(object):
			object.take_damage(attack)
			queue_free()
