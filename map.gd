extends Node

func handle_dropped_item(item_scene: Resource, position: Vector2):
	print("map dropped gun")
	var dropped_item = item_scene.instantiate()
	dropped_item.global_position = position
	add_child(dropped_item)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
