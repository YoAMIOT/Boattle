extends Node

var network = null;
var ip : String = "";
var port : int = 4180;
var playerName : String = "";

signal successfullyConnected;
signal failedToConnect;



func connectToServer():
	network = NetworkedMultiplayerENet.new();
	network.create_client(ip, port);
	get_tree().set_network_peer(network);
	var _signalFailedConnect = network.connect("connection_failed", self, "connectionFailed");
	var _signalSuccessConnect = network.connect("connection_succeeded", self, "connectionSucceeded");

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
