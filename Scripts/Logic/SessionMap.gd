extends Node
class_name SessionMap

var shapesInScene:Dictionary
var craftablesInScene:Dictionary

func _init():
	var playersNode = Node.new()
	playersNode.set_name("Players")
	add_child(playersNode)
	
	if MultiplayerHandler.is_multiplayer():
		var playerSpawner = MultiplayerSpawner.new()
		playerSpawner.set_name("PlayerSpawner")
		playerSpawner.set_spawn_limit(MultiplayerHandler.get_player_limit())
		playerSpawner.set_spawn_path("../Players")
		playerSpawner.add_spawnable_scene("res://Scenes/Logic/Player.tscn")
		playerSpawner.set_spawn_function(spawn_player)
		add_child(playerSpawner)
	
	var GUILayer = CanvasLayer.new()
	GUILayer.set_layer(10)
	GUILayer.set_follow_viewport(false)
	GUILayer.set_name("GUILayer")
	add_child(GUILayer)

func _ready():
	if $Preloads.player:
		if MultiplayerHandler.multiplayer.is_server():
			MultiplayerHandler.multiplayer.peer_connected.connect(add_player)
			MultiplayerHandler.multiplayer.peer_disconnected.connect(del_player)

			# Spawn already connected players
			for id in multiplayer.get_peers():
				add_player(id)

			# Spawn the local player unless this is a dedicated server export.
			if not OS.has_feature("dedicated_server"):
				create_player()
	
	if $Preloads.UI:
		pass
		create_UI()
	
	send_everchild_to_minimap()
	
	GameManager.set_session_map(self)

func spawn_player(player):
	print("Spawnning "+player.name)
	return player

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)

func create_player():
	var player = $Preloads.player.instantiate()
	var id = 1
	player.playerID = id	
	player.name = "Player %d" %id
	player.userData = GameManager.get_user_data()
	$Players.add_child(player)
	GameManager.set_player(player)

func add_player(id: int):
	rpc_id(id, "get_user_data")

@rpc("authority")
func get_user_data():
	rpc_id(1, "receive_user_data", GameManager.get_user_data())

@rpc("any_peer")
func receive_user_data(data):
	var player = $Preloads.player.instantiate()
	var id = multiplayer.get_remote_sender_id()
	print("Burda: "+str(id))
	player.playerID = id	
	player.name = "Player %d" %id
	player.userData = data
	$Players.add_child(player)

func del_player(id: int):
	print("peer disconnected at: ", id)
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()

func create_UI():
	var UI = $Preloads.UI.instantiate()
	$GUILayer.add_child(UI)
	GameManager.set_UI(UI)

func set_global_session_shapes():
	GameManager.set_shapes(self.shapesInScene)

func set_global_session_craftables():
	GameManager.set_craftables(self.craftablesInScene)

func send_minimap_recursion(node)->void:
	if node.is_in_group("minimapable_object"):
		send_to_minimap(node)
	for N in node.get_children():
		send_minimap_recursion(N)
	pass

func send_everchild_to_minimap()->void:
	for N in self.get_children():
		send_minimap_recursion(N)

func send_to_minimap(node)->void:
	if GameManager.get_minimap() != null:
		GameManager.get_minimap().receive_object(node)
	else:
		print_debug("Can not send object to non-existent globalMinimap.")
	pass

func get_shape_name_from_numpad(current:String, number:int)->String:
	if shapesInScene.has(number):
		if shapesInScene[number] is Dictionary:
			for key in shapesInScene[number].keys():
				if shapesInScene[number][key].get_name() == current:
					if shapesInScene[number].has(key + 1):
						return shapesInScene[number][key + 1].get_name()
					else:
						return shapesInScene[number][1].get_name()
			return shapesInScene[number][1].get_name()
		else:
			return shapesInScene[number].get_name()
	else:
		return "Null"
	

# warning-ignore:unused_argument
func _physics_process(delta):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
