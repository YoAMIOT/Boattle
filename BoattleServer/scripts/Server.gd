extends Node

var network : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new();
var ip : String = "Unknow Address";
var port : int = 4180;
var maxPlayers : int = 20;
var upnp : UPNP = UPNP.new();
var serverStarted : bool = false;
onready var Log = get_node("Ui/Log");



func _ready():
	OS.set_window_fullscreen(false);
	get_tree().set_auto_accept_quit(false)
	var error = upnp.discover(2000, 2, "InternetGatewayDevice");
	DataManager.printError(error);
	ip = upnp.query_external_address();
	error = upnp.add_port_mapping(port, port, "BoattleServer", "UDP");
	DataManager.printError(error);
	error = upnp.add_port_mapping(port, port, "BoattleServer", "TCP");
	DataManager.printError(error);
	get_node("Ui/IpLabel").text = ip;


func _on_ValidateButton_pressed():
	maxPlayers = get_node("Ui/MaxPlayerMenu/Selector").value;
	get_node("Ui/MaxPlayerMenu").visible = false;
	get_node("Ui/StartServer").disabled = false;


func _on_StartServer_pressed():
	serverStarted = true;
	get_node("Ui/StartServer").disabled = true;
	var error = network.create_server(port, maxPlayers);
	DataManager.printError(error);
	get_tree().set_network_peer(network);
	Log.logPrint("===Server Started===");
	Log.logPrint("=Currently running on " + ip + "=");
	error = network.connect("peer_connected", self, "peerConnected");
	DataManager.printError(error);
	error = network.connect("peer_disconnected", self, "peerDisconnected");
	DataManager.printError(error);
	get_node("TurnCooldown").start()



func peerConnected(playerId : int):
	Log.logPrint("!- User" + str(playerId) + " Connected -!");

func peerDisconnected(playerId : int):
	Log.logPrint("!- User" + str(playerId) + " Disconnected -!");
	DataManager.playerDisconnected(playerId);
	rpc_id(0, "killPuppet", playerId);

func kickPlayer(playerId):
	rpc_id(playerId, "disconnectFromServer");
	network.disconnect_peer(playerId);



func _notification(what : int):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit();

func _on_Close_pressed():
	_notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST);



remote func newConnectionEstablished(playerName : String, playerId : int):
	if not DataManager.playersDatas.has(playerName):
		var position : Vector2 = Vector2(0 ,0);
		DataManager.saveDatasOfAPlayer(playerName, position);
	if not DataManager.connectedPlayersDictionnary.has(playerName):
		var playerPosition : Vector2 = Vector2(DataManager.playersDatas[playerName].posX, DataManager.playersDatas[playerName].posY);
		DataManager.playerConnected(playerId, playerName);
		rpc_id(0, "spawnPuppet", playerId, playerName, playerPosition);
		rpc_id(playerId, "spawnClientPlayer", playerPosition);
	else:
		kickPlayer(playerId);



remote func receivePos(position : Vector2, playerName : String):
	DataManager.saveDatasOfAPlayer(playerName, position);



func _on_TurnCooldown_timeout() -> void:
	var worldState : Dictionary = {};
	for p in DataManager.connectedPlayersDictionnary:
		worldState[p] = {
			"playerName" : DataManager.connectedPlayersDictionnary[p],
			"posX" : DataManager.playersDatas[DataManager.connectedPlayersDictionnary[p]].posX,
			"posY" : DataManager.playersDatas[DataManager.connectedPlayersDictionnary[p]].posY
		};
	rpc_id(0, "receiveWorldState", worldState);
