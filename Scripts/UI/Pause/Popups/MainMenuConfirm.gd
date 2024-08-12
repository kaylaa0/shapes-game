extends ConfirmationDialog

func _ready():
	get_ok_button().set_text("Confirm")
# warning-ignore:return_value_discarded
	get_ok_button().connect("pressed",Callable(self,"ok_pressed"))
# warning-ignore:return_value_discarded
	add_button("Save", false, "save_game")

func ok_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
	get_tree().paused = false

func save_game():
	pass

#func _process(delta):
#	pass
