extends Node

var network = null;
var ip : String = "";
var port : int = 4180;

signal successfullyConnected;
signal failedToConnect;



func connectToServer():
	network = NetworkedMultiplayerENet.new();
	network.create_client(ip, port);
	get_tree().set_network_peer(network);
	var error = network.connect("connection_failed", self, "connectionFailed");
	DataManager.printError(error);
	error = network.connect("connection_succeeded", self, "connectionSucceeded");
	DataManager.printError(error);

func connectionFailed():
	emit_signal("failedToConnect");

func connectionSucceeded():
	emit_signal("successfullyConnected");
	rpc_id(1, "newConnectionEstablished", DataManager.datas["playerName"], get_tree().get_network_unique_id());

func resetNetworkPeer():
	if get_tree().has_network_peer():
		network.disconnect("connection_failed", self, "connectionFailed");
		network.disconnect("connection_succeeded", self, "connectionSucceeded");
		get_tree().network_peer = null



remote func spawnPuppet(playerId : int, playerName : String, puppetPosition : Vector2):
	get_node("/root/MainMenu/Main").spawnPuppet(playerId, playerName, puppetPosition);

remote func spawnClientPlayer(position : Vector2):
	get_node("/root/MainMenu/Main").spawnClientPlayer(position);

remote func killPuppet(playerId : int):
	get_node("/root/MainMenu/Main").killPuppet(playerId);



func sendPosToServer(position : Vector2):
	rpc_id(1, "receivePos", position, DataManager.datas["playerName"], get_tree().get_network_unique_id());
