extends MarginContainer

var selectedCraft:MyCraftable = null
@onready var scrollContainer = get_node("CraftMenuMargin/HSplitContainer/HSplitContainer/MarginContainer/HBoxContainer/ScrollContainer")
@onready var popupContainer = get_node("CraftMenuMargin/HSplitContainer/MarginContainer/Popup")

func _ready():
# warning-ignore:return_value_discarded
	GameManager.get_player().connect("cmUpdateNeeded",Callable(self,"update_contents"))
# warning-ignore:return_value_discarded
	GameManager.get_player().connect("cmaUpdateNeeded",Callable(self,"update_content"))
	#await get_tree().idle_frame # Map needs to be loaded
	#await get_tree().idle_frame # AI will set craftables. Not implemented yet.
	set_focus_mode(0)
	for key in GameManager.get_craftables().keys():
		if GameManager.get_craftables()[key] is MyBasic:
			scrollContainer.init_craftable(GameManager.get_craftables()[key])
			popupContainer.init_craftable(GameManager.get_craftables()[key])
		else:
			print_debug("GameManager has undefined craftable stored.")
	
	scrollContainer.update_contents()
	popupContainer.update_contents()
	popupContainer.resize_fit()
	self.set_size(Vector2(self.get_size()[0],150))

func update_content(craftable, state)->void:
	scrollContainer.update_content(craftable, state)
	popupContainer.update_content(craftable, state)

func update_contents()->void:
	scrollContainer.update_contents()
	popupContainer.update_contents()

#func _process(delta):
#	pass
