extends Button

signal updateNeeded
signal selectUpdate(name)

func _ready():
# warning-ignore:return_value_discarded
	connect("pressed",Callable(self,"_button_pressed"))
	pass

func _button_pressed():
	set_focus_mode(0)
	emit_signal("selectUpdate", self.get_name().replace(" button",""))
#	GameManager.get_player().set_selected_craftable(self.get_name().replace(" button","")) this is moved to main button for identification of sender
	for child in get_parent().get_children():
		print(child.get_name())
		print(child.get_children())
	emit_signal("updateNeeded")

func _physics_process(_delta):
	for child in get_parent().get_children():
		if child.get_name() == self.get_name().replace(" button",""):
			if child.get_can_craft():
				print(2)

#func _process(delta):
#	pass
