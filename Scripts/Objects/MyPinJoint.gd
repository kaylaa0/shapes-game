extends PinJoint2D


func _ready():
	pass

# warning-ignore:unused_argument
func _physics_process(_delta):
	if get_node_a() != null:
		set_global_position(get_node(get_node_a()).get_global_position())
