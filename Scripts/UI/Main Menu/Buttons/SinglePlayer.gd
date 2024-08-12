extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SinglePlayer_pressed():
	get_owner().get_node("MainMenu").hide()
	get_owner().get_node("SinglePlayer").show()
	MultiplayerHandler.set_is_multiplayer(false)
	pass # Replace with function body.
