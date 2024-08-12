extends Node


func _ready():
	pass

# warning-ignore:unused_argument
func _physics_process(delta):
	for child in get_children():
		child.set_global_position(Vector2(get_parent().get_global_position().x, get_parent().get_global_position().y -25))
