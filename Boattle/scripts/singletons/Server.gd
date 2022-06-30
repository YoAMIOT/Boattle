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
	print("! Failed to connect !");
	emit_signal("failedToConnect");

func connectionSucceeded():
	print("===Sucessfully connected===");
	emit_signal("successfullyConnected");

func resetNetworkPeer():
	if get_tree().has_network_peer():
		network.disconnect("connection_failed", self, "connectionFailed");
		network.disconnect("connection_succeeded", self, "connectionSucceeded");
		get_tree().network_peer = null
