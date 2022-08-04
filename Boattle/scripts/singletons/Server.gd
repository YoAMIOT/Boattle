extends Node

var network = null;
var ip : String = "";
var port : int = 4180;
var MainInstance : PackedScene = load("res://scenes/Main.tscn");

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

func disconnectFromServer() -> void:
	resetNetworkPeer();
	get_node("/root/MainMenu").resetMenus();
	get_node("/root/MainMenu/Main").queue_free();
	var mainInstance = MainInstance.instance();
	get_node("/root/MainMenu").add_child(mainInstance);
	mainInstance.visible = false
	yield(get_tree().create_timer(0.1), "timeout");
	mainInstance.name = "Main";

remote func kickedFromServer(reason : String) -> void:
	disconnectFromServer();
	get_node("/root/MainMenu").showKickMessage(reason);



func sendPasswordValidationRequest(registration : bool, password : String) -> void:
	rpc_id(1, "receivePasswordValidationRequest", registration, password, DataManager.datas["playerName"]);

remote func authentication(registration : bool) -> void:
	get_node("/root/MainMenu/PasswordPage").visible = true;
	if registration:
		get_node("/root/MainMenu/PasswordPage/Registration").visible = true;
	elif not registration:
		get_node("/root/MainMenu/PasswordPage/AlreadyRegistered").visible = true;

remote func logIn(playerPosition : Vector2, playerShipsDatas : Dictionary, currentHealth : int) -> void:
	get_node("/root/MainMenu/Main").spawnClientPlayer(playerPosition, playerShipsDatas, currentHealth);
	get_node("/root/MainMenu").enterGame();
	get_node("/root/MainMenu/PasswordPage").reset();
	get_node("/root/MainMenu/PasswordPage").visible = false;

remote func wrongPassword() -> void:
	get_node("/root/MainMenu/PasswordPage").wrongPassword();



remote func spawnPuppet(playerId : int, playerName : String, puppetPosition : Vector2, maxHealth : int, health : int) -> void:
	get_node("/root/MainMenu/Main").spawnPuppet(playerId, playerName, puppetPosition, maxHealth, health);

remote func killPuppet(playerId : int) -> void:
	get_node("/root/MainMenu/Main").killPuppet(playerId);



func sendTurnDataToServer(action : String, position : Vector2, radius : float = 0.1) -> void:
	rpc_id(1, "receiveTurnData", action, position, DataManager.datas["playerName"], radius);

remote func receiveWorldState(worldState : Dictionary) -> void:
	for p in worldState:
		if get_tree().get_network_unique_id() == p:
			if get_node("/root/MainMenu/Main").has_node("Boat"):
				var newPosition : Vector2 = Vector2(worldState[p].posX, worldState[p].posY);
				get_node("/root/MainMenu/Main/Boat").moveClientBoat(newPosition);
		elif get_tree().get_network_unique_id() != p:
			var newPosition : Vector2 = Vector2(worldState[p].posX, worldState[p].posY);
			if !get_node("/root/MainMenu/Main/Players/").has_node(str(p)):
				spawnPuppet(p, worldState[p].playerName, newPosition, 200, 200);
			get_node("/root/MainMenu/Main/Players/" + str(p)).move(newPosition);

remote func shootOnPos(playerName : String, position : Vector2, radiusMultiplier : float, targets : Dictionary) -> void:
	get_node("/root/MainMenu/Main").shootOnPos(playerName, position, radiusMultiplier, targets);



remote func turnSwitch(turnState : bool) -> void:
	if get_node("/root/MainMenu/Main").has_node("Boat"):
		get_node("/root/MainMenu/Main/Boat").setTurn(turnState);
