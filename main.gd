extends Control

var username : String = ""

const DEFAULT_HOST : String = "localhost"
const DEFAULT_PORT : int = 8005

func _ready():
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_host_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	var err : Error = peer.create_server(DEFAULT_PORT)
	if (err):
		print("[ERR] Error creating server. Make sure the port is free")
		return
	
	multiplayer.multiplayer_peer = peer
	print("Server started on port %s..." % DEFAULT_PORT)
	
	start_chat()

func _on_join_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(DEFAULT_HOST, DEFAULT_PORT)
	if (err):
		print("error creating client:" + err)
	multiplayer.multiplayer_peer = peer
	start_chat()

func _peer_connected(id : int):
	print("_peer_connected. I'm " + str(multiplayer.get_unique_id()) + " and got connexion from "  + str(id))

func _peer_disconnected(id : int):
	print("_peer_disconnected. I'm " + str(multiplayer.get_unique_id()) + " and got connexion from "  + str(id))

func _on_connected_to_server():
	print("Connected to server signal emitted by " + str(multiplayer.get_unique_id()))
	
func _on_connection_failed():
	print("Connection failed signal emitted by " + str(multiplayer.get_unique_id()))
	
func _on_server_disconnected():
	show_menu()
	print("Server Disconnected")
	
func _on_user_message_gui_input(event : InputEvent):
	if event.is_action_pressed("ui_text_newline") and %UserMessage.text != "":
		send_message.rpc(%UserMessage.text)
		%UserMessage.clear()

@rpc("any_peer", "call_local", "reliable")
func send_message(text: String):
	%AllMessages.text += "%d : %s\n" % [multiplayer.get_remote_sender_id(), text]

func start_chat():
	var un : String = %Username.text
	if %Username.text == "" :
		un = generate_random_name()
	%PeerIDLabel.text = "Username: %s\n" % un
	%PeerIDLabel.text += "PeerID: %s" % str(multiplayer.get_unique_id())
	%MenuPanel.hide()
	%ChatPanel.show()

func show_menu():
	%MenuPanel.show()
	%ChatPanel.hide()

func generate_random_name() -> String:
	var adjective : Array = [
		"awesome",
		"handsome",
		"busy",
		"pensive",
		"smart",
		"tricky",
		"mr",
		"feisty",
	]
	var noun : Array = [
		"lemur",
		"alien",
		"hamster",
		"robot",
		"vic",
		"drake",
		"sheep",
		"mouse"
	]
	return "%s_%s" % [adjective.pick_random(), noun.pick_random()]
