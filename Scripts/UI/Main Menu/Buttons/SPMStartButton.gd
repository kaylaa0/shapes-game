extends Button


func _ready():
	pass 

#func _process(delta):
#	pass


func _on_StartButton_pressed():
	if get_owner().get_node("SinglePlayer").getSelectedMap() != null:
# warning-ignore:return_value_discarded
		get_tree().change_scene_to_file("res://Scenes/Maps/"+str(get_owner().get_node("SinglePlayer").getSelectedMap())+".tscn")
	else:
		get_owner().get_node("SPMNoMapSelected").popup()
