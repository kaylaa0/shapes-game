extends Node

@export var GRAVITY = 980
var mapNames = []

# Called when the node enters the scene tree for the first time.
func _ready():
	ProjectSettings.set_setting("physics/2d/default_gravity", GRAVITY)
	mapNames.append("MeadowCastle")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
