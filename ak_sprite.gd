extends CharacterBody2D

@onready var looting_area = $"CollisionShape2D"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func loot_ak():
	print("stuff")
	queue_free()
