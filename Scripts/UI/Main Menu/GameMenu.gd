extends Control

var isPaused

# Called when the node enters the scene tree for the first time.
func _ready():
	for N in self.get_children():
			if N.is_in_group("menu") and N.is_visible():
				N.hide()
	get_node("MainMenu").show()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
