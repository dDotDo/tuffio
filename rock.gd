extends CharacterBody2D

var health = 3

func take_damage(damage: int):
	print('Rock got hit')
	health -= damage	
	if health <= 0:
		destroy()
	
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, 'scale', scale - Vector2.ONE * 1/(health * 3), 0.2)
		
func destroy():
	queue_free()
