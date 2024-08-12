extends Button

func _ready():
	pass

func _on_QuitDesktop_pressed():
	get_owner().get_node("ExitGameConfirm").popup()
	
#func _process(delta):
#	pass



