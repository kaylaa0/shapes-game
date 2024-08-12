extends MyCraftable
class_name MyBasic

# Must have a Sprite2D node defined in scene.

var canBeCraftedNow:bool = false : get = get_can_craft, set = set_can_craft # Will set to true if recipe is met in screen.

signal valueset

func _init():
	self.set_basic_version(self)

func _ready():
	pass

func init_building(buildingHolder:MyCraftable)->void:
	buildingHolder.set_basic_version(self)
	buildingHolder.set_building_version(buildingHolder)
	buildingHolder.set_recipe(self.get_recipe())

func can_craft():
	canBeCraftedNow = true
	emit_signal("valueset")

func cant_craft():
	canBeCraftedNow = false
	emit_signal("valueset")

# warning-ignore:unused_argument
func set_can_craft(state:bool)->void:
	print_debug("Instead use can_craft(), cant_craft()")

func get_can_craft()->bool:
	return canBeCraftedNow

#func _process(delta):
#	pass
