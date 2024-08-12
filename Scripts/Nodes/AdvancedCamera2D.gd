extends Camera2D

class_name AdvancedCamera2D

var followedObject
var speed = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_followed_object(object):
	followedObject = object

func follow(delta):
	if followedObject != null:
		set_global_position(lerp(get_global_position(), followedObject.get_global_position(), delta*speed))
	pass

func _physics_process(delta):
	follow(delta)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
