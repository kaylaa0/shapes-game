extends MenuButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for map in MapManager.mapNames:
		get_popup().add_item(map)
# warning-ignore:return_value_discarded
	get_popup().connect("id_pressed",Callable(self,"_on_item_pressed"))
	pass # Replace with function body.

func _on_item_pressed(id):
	set_text(get_popup().get_item_text(id))
	get_owner().get_node("MultiPlayer").setSelectedMap(get_popup().get_item_text(id))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
