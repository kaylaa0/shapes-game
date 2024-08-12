extends Button

signal updateNeeded

func _ready():
# warning-ignore:return_value_discarded
	connect("pressed",Callable(self,"_button_pressed"))
	pass

func _button_pressed():
	set_focus_mode(0)
	GameManager.get_player().set_selected_spawn(self.get_name().replace(" button",""))
	emit_signal("updateNeeded")

#func _process(delta):
#	pass
