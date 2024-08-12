extends Node

#var MultiPlayer:MultiplayerAPI = MultiplayerAPI.create_default_interface()

var ip_adress :String = "Undefined": get = get_ip_adress
var ip_label :Label
var ip_regex :RegEx = RegEx.new()
var port_regex :RegEx = RegEx.new()
var number_dot_regex :RegEx = RegEx.new()

var isMultiPlayer:bool = false :set = set_is_multiplayer, get = is_multiplayer
var playerLimit:int = 6 :set = set_player_limit, get = get_player_limit

func _init():
	ip_regex.compile("(\\b25[0-5]|\\b2[0-4][0-9]|\\b[01]?[0-9][0-9]?)(\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}")
	port_regex.compile("^((6553[0-5])|(655[0-2][0-9])|(65[0-4][0-9]{2})|(6[0-4][0-9]{3})|([1-5][0-9]{4})|([0-5]{0,5})|([0-9]{1,4}))$")
	number_dot_regex.compile("(\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}|\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.|\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}|\\d{1,3}\\.\\d{1,3}\\.|\\d{1,3}\\.\\d{1,3}|\\d{1,3}\\.|\\d{1,3})")
	
	if OS.has_feature("windows"):
		if OS.has_environment("COMPUTERNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
	elif OS.has_feature("x11"):
		if OS.has_environment("HOSTNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)
	elif OS.has_feature("OSX"):
		if OS.has_environment("HOSTNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)

func _ready():
	pass
	# MultiPlayer.server_relay = false
	
	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server")
		create_server.call_deferred()
		
func get_ip_adress()->String:
	return ip_adress

func set_is_multiplayer(toset:bool):
	isMultiPlayer = toset

func is_multiplayer()->bool:
	return isMultiPlayer

func set_player_limit(toset:int):
	playerLimit = toset
	
func get_player_limit()->int:
	return playerLimit

func create_server(port:int):
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 6)
	multiplayer.set_multiplayer_peer(peer)
	set_player_limit(6)
	start_game()
	
func create_client(ip:String, port:int):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client")
		return
	multiplayer.set_multiplayer_peer(peer)
	start_game()

func start_game():
	# Hide the UI and unpause to start the game.
	get_node("/root/ShapesGame/GameMenu").hide()
	# Only change level on the server.
	# Clients will instantiate the level via the spawner.
	if multiplayer.is_server():
		print("server")
		change_level.call_deferred(load(GameManager.selectedScene))


# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = get_node("/root/ShapesGame/Level")
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())

# The server can restart the level by pressing HOME.
func _input(event):
	if not multiplayer.is_server():
		return
	if event.is_action("ui_home") and Input.is_action_just_pressed("ui_home"):
		change_level.call_deferred(load(GameManager.selectedScene))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
