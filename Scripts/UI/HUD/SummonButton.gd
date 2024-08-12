extends Control

var selectedSummon:MyShape = null
@onready var ninePatch = get_node("SummonMenu/AnimatedNinePatch")

func _ready():
	#await get_tree().idle_frame # Map needs to be loaded
	#await get_tree().idle_frame # Spawner will set shapes.
	set_focus_mode(0)
	for key in GameManager.get_shapes().keys():
		if GameManager.get_shapes()[key] is Dictionary:
			ninePatch.init_dict(GameManager.get_shapes()[key])
		elif GameManager.get_shapes()[key] is MyShape:
			ninePatch.init_shape(GameManager.get_shapes()[key])
		else:
			print_debug("GameManager has undefined shape stored.")
# warning-ignore:return_value_discarded
	GameManager.get_player().connect("spawnedSignal",Callable(ninePatch,"update_contents"))
	ninePatch.update_contents()
	







