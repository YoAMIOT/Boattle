extends Node

var network = null;
var ip : String = "";
var port : int = 4180;

signal successfullyConnected;
signal failedToConnect;



func connectToServer() -> void:
	network = NetworkedMultiplayerENet.new();
	network.create_client(ip, port);
	get_tree().set_network_peer(network);
	var error = network.connect("connection_failed", self, "connectionFailed");
	DataManager.printError(error);
	error = network.connect("connection_succeeded", self, "connectionSucceeded");
	DataManager.printError(error);

func connectionFailed() -> void:
	emit_signal("failedToConnect");

func connectionSucceeded() -> void:
	emit_signal("successfullyConnected");
	rpc_id(1, "newConnectionEstablished", DataManager.datas["playerName"], get_tree().get_network_unique_id());

func resetNetworkPeer() -> void:
	if get_tree().has_network_peer():
		network.disconnect("connection_failed", self, "connectionFailed");
		network.disconnect("connection_succeeded", self, "connectionSucceeded");
		get_tree().network_peer = null

remote func kickedFromServer(reason : String) -> void:
	get_node("/root/MainMenu").resetMenus();
	get_node("/root/MainMenu").showKickMessage(reason);



func sendPasswordValidationRequest(registration : bool, password : String) -> void:
	rpc_id(1, "receivePasswordValidationRequest", registration, password, DataManager.datas["playerName"]);

remote func authentication(registration : bool) -> void:
	get_node("/root/MainMenu/PasswordPage").visible = true;
	if registration == true:
		get_node("/root/MainMenu/PasswordPage/Registration").visible = true;
	elif registration == false:
		get_node("/root/MainMenu/PasswordPage/AlreadyRegistered").visible = true;

remote func logIn(playerPosition : Vector2) -> void:
	spawnClientPlayer(playerPosition);
	get_node("/root/MainMenu").enterGame();
	get_node("/root/MainMenu/PasswordPage").reset();
	get_node("/root/MainMenu/PasswordPage").visible = false;

remote func wrongPassword() -> void:
	get_node("/root/MainMenu/PasswordPage").wrongPassword();



remote func spawnPuppet(playerId : int, playerName : String, puppetPosition : Vector2) -> void:
	get_node("/root/MainMenu/Main").spawnPuppet(playerId, playerName, puppetPosition);

remote func spawnClientPlayer(position : Vector2) -> void:
	get_node("/root/MainMenu/Main").spawnClientPlayer(position);

remote func killPuppet(playerId : int) -> void:
	get_node("/root/MainMenu/Main").killPuppet(playerId);



func sendPosToServer(position : Vector2) -> void:
	rpc_id(1, "receivePos", position, DataManager.datas["playerName"]);

remote func receiveWorldState(worldState : Dictionary) -> void:
	for p in worldState:
		if get_tree().get_network_unique_id() != p:
			var newPosition : Vector2 = Vector2(worldState[p].posX, worldState[p].posY);
			if !get_node("/root/MainMenu/Main/Players/").has_node(str(p)):
				spawnPuppet(p, worldState[p].playerName, newPosition);
			get_node("/root/MainMenu/Main/Players/" + str(p)).move(newPosition);
