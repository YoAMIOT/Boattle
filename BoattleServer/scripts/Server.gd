extends Node

var network : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new();
var ip : String;
var port : int = 4180;
var maxPlayers : int = 20;
var upnp : UPNP = UPNP.new();
var serverStarted : bool = false;
onready var Log = get_node("Ui/Log");



func _ready():
	OS.set_window_fullscreen(false);
	get_tree().set_auto_accept_quit(false)
	upnp.discover(2000, 2, "InternetGatewayDevice");
	ip = upnp.query_external_address();
	upnp.add_port_mapping(port, port, "BoattleServer", "UDP");
	upnp.add_port_mapping(port, port, "BoattleServer", "TCP");
	get_node("Ui/IpLabel").text = ip;


func _on_ValidateButton_pressed():
	maxPlayers = get_node("Ui/MaxPlayerMenu/Selector").value;
	get_node("Ui/MaxPlayerMenu").visible = false;
	get_node("Ui/StartServer").disabled = false;


func _on_StartServer_pressed():
	serverStarted = true;
	get_node("Ui/StartServer").disabled = true;
	network.create_server(port, maxPlayers);
	get_tree().set_network_peer(network);
	Log.logPrint("===Server Started===");
	Log.logPrint("=Currently running on " + ip + "=");
	var error =network.connect("peer_connected", self, "peerConnected");
	printError(error);
	error = network.connect("peer_disconnected", self, "peerDisconnected");
	printError(error);



func peerConnected(playerId):
	Log.logPrint("!- User" + str(playerId) + " Connected -!");
	#TODO Load last known pos
	var puppetPosition : Vector2 = Vector2(0,0);
	rpc_id(0, "spawnPuppet", playerId, puppetPosition);

func peerDisconnected(playerId):
	Log.logPrint("!- User" + str(playerId) + " Disconnected -!");
	rpc_id(0, "killPuppet", playerId);



func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit();

func _on_Close_pressed():
	_notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST);



func printError(error):
	if error != 0:
		print("ERROR: ", error);



remote func receivePos(position : Vector2, playerName : String, playerId : int):
	Log.logPrint(str(position) + " ;"+ playerName+ " ;"+ str(playerId));
