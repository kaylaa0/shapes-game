extends Node

var cmdLineArguments:Dictionary = {}

# Game Settings
var gameLanguage:Dictionary #Language

var stickyScript = preload("res://Scripts/Objects/StickyShape.gd")
var pinJointScript = preload("res://Scripts/Objects/MyPinJoint.gd")
var rotationDisableScript = preload("res://Scripts/Objects/RotationDisable.gd")
var topNodeScript = preload("res://Scripts/Nodes/Bunch/TopCasts.gd")
var rightNodeScript = preload("res://Scripts/Nodes/Bunch/RightCasts.gd")
var leftNodeScript = preload("res://Scripts/Nodes/Bunch/LeftCasts.gd")

var userData:String = "user" # This is dummy for now, in the future userdata will be here and send to server
var globalPlayer:Node2D : get = get_player, set = set_player
var globalSessionMap:SessionMap : get = get_session_map, set = set_session_map
var globalMinimap:Minimap : get = get_minimap, set = set_minimap
var globalSessionShapes:Dictionary : get = get_shapes, set = set_shapes
var globalSessionCraftables:Dictionary : get = get_craftables, set = set_craftables
var globalUI:UI : get = get_UI, set = set_UI
var mapLoaded:bool = false

var selectedScene:String

var debug:bool=true
var defaultPort:String = "5000"
var defaultIP:String = "192.168.1.36"
var debugMap:String = "MeadowCastle"

func _ready():
	get_cmd_line_arguments()
# warning-ignore:return_value_discarded
	set_game_language()
	

func get_user_data():
	return userData

func set_game_language()->bool:
	var file = FileAccess
	if(cmdLineArguments.has("language")):
		if file.file_exists("res://Data/Language/"+cmdLineArguments["language"]+".json"):
			file = file.open("res://Data/Language/"+cmdLineArguments["language"]+".json", FileAccess.READ)
			var test_json_conv = JSON.new()
			test_json_conv.parse(file.get_as_text())
			gameLanguage = test_json_conv.get_data()
			file.close()
			return true
		else:
			print_debug("User requested game to launch with unimplemented language: "+cmdLineArguments["language"])
	if file.file_exists("res://Data/Language/english.json"):
		file = file.open("res://Data/Language/english.json", FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		gameLanguage = test_json_conv.get_data()
		file.close()
		return true
	else:
		print_debug("Default language english can not be found in data folder.")
		return false


func get_cmd_line_arguments():
	for argument in OS.get_cmdline_args():
		# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			cmdLineArguments[key_value[0].lstrip("--")] = key_value[1]

func get_shape(name:String)->MyShape:
	for key in get_shapes().keys():
		if get_shapes()[key] is Dictionary:
			for key2 in get_shapes()[key].keys():
				if get_shapes()[key][key2].get_name() == name:
					return get_shapes()[key][key2]
		elif get_shapes()[key].get_name() == name:
			return get_shapes()[key]
	print_debug("Requested shape is not found in Session Shapes.")
	return null

func set_player(player:Node2D)->void:
	if globalPlayer == null:
		globalPlayer = player
	else:
		print_debug("There is already a global player controller.")

func get_player()->Player:
	return globalPlayer

func set_session_map(scene:SessionMap)->void:
	if globalSessionMap == null:
		globalSessionMap = scene
	else:
		print_debug("There is already a global session scene.")

func get_session_map()->SessionMap:
	return globalSessionMap

func set_minimap(minimap:Minimap)->void:
	if globalMinimap == null:
		globalMinimap = minimap
	else:
		print_debug("There is already a global minimap.")

func get_minimap()->Minimap:
	return globalMinimap

func set_shapes(anArray:Dictionary)->void:
	globalSessionShapes = anArray

func get_shapes()->Dictionary:
	return globalSessionShapes

func set_craftables(anArray:Dictionary)->void:
	globalSessionCraftables = anArray

func get_craftables()->Dictionary:
	return globalSessionCraftables

func set_UI(ui:UI)->void:
	if globalUI == null:
		globalUI = ui
	else:
		print_debug("There is already a global UI.")

func get_UI()->UI:
	return globalUI

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
