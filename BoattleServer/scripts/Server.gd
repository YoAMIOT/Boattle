extends Node

var network : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new();
var ip : String = "Unknow Address";
var port : int = 4180;
var maxPlayers : int = 20;
var upnp : UPNP = UPNP.new();
var serverStarted : bool = false;
var turn : bool = false;
onready var Log = get_node("Ui/Log");



func _ready() -> void:
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

func _on_ValidateButton_pressed() -> void:
	maxPlayers = get_node("Ui/MaxPlayerMenu/Selector").value + 1;
	refreshPlayerCountLabel();
	get_node("Ui/MaxPlayerMenu").visible = false;
	get_node("Ui/StartServer").disabled = false;

func _on_StartServer_pressed() -> void:
	serverStarted = true;
	get_node("Ui/StartServer").disabled = true;
	var error = network.create_server(port, maxPlayers);
	DataManager.printError(error);
	get_tree().set_network_peer(network);
	Log.logPrint("=== Server started and running on " + ip + " ===");
	error = network.connect("peer_connected", self, "peerConnected");
	DataManager.printError(error);
	error = network.connect("peer_disconnected", self, "peerDisconnected");
	DataManager.printError(error);
	get_node("TurnCooldown").start()



func peerConnected(playerId : int) -> void:
	if DataManager.connectedPlayersDictionary.size() == maxPlayers - 1:
		kickPlayer(playerId, "Server full");

func peerDisconnected(playerId : int) -> void:
	Log.logPrint("!- " + DataManager.connectedPlayersDictionary[playerId] + " Disconnected -!");
	DataManager.playerDisconnected(playerId);
	refreshPlayerCountLabel();
	if get_node("PasswordTimers").has_node(str(playerId)):
		get_node("PasswordTimers/" + str(playerId)).disconnect("timeout", self, "kickPlayer");
		get_node("PasswordTimers/" + str(playerId)).queue_free();
	rpc_id(0, "killPuppet", playerId);

remote func newConnectionEstablished(playerName : String, playerId : int) -> void:
	var registration : bool = false;
	Log.logPrint("!- " + playerName + " Connected -!");
	if not DataManager.playersPasswordsDictionary.has(playerName):
		var position : Vector2 = Vector2(0 ,0);
		DataManager.saveDatasOfAPlayer(playerName, position);
		DataManager.createShipStatsForPlayer(playerName);
		registration = true
	var hasPlayerConnected : bool = DataManager.isPlayerConnected(playerName);
	if hasPlayerConnected:
		kickPlayer(playerId, "Player already connected");
	elif not hasPlayerConnected:
		var playerPosition : Vector2 = Vector2(DataManager.playersDatasDictionary[playerName].posX, DataManager.playersDatasDictionary[playerName].posY);
		DataManager.playerConnected(playerId, playerName);
		refreshPlayerCountLabel();
		rpc_id(0, "spawnPuppet", playerId, playerName, playerPosition);
		rpc_id(playerId, "authentication", registration);
		var timeOutTimer : Timer = Timer.new();
		get_node("PasswordTimers").add_child(timeOutTimer);
		timeOutTimer.name = str(playerId);
		timeOutTimer.wait_time = 60;
		timeOutTimer.one_shot = true;
		var error = timeOutTimer.connect("timeout", self, "kickPlayer", [playerId, "You did not enter password in time, please retry"]);
		DataManager.printError(error);
		timeOutTimer.start();

remote func receivePasswordValidationRequest(registration : bool, password : String, playerName : String) -> void:
	PasswordManager.validatePassword(registration, password, playerName);

func logIn(playerId : int, playerName : String) -> void:
	get_node("PasswordTimers/" + str(playerId)).disconnect("timeout", self, "kickPlayer");
	var playerPosition : Vector2 = Vector2(DataManager.playersDatasDictionary[playerName].posX, DataManager.playersDatasDictionary[playerName].posY);
	var playerShipsDatas : Dictionary = DataManager.shipsDictionary[DataManager.playerShipsStatsDictionary[playerName].ship];
	Log.logPrint("!- " + playerName + " authentified -!");
	rpc_id(playerId, "logIn", playerPosition, playerShipsDatas);
	get_node("PasswordTimers/" + str(playerId)).queue_free();

func wrongPasswordEntered(playerId : int) -> void:
	rpc_id(playerId, "wrongPassword");

func kickPlayer(playerId : int, reason : String) -> void:
	Log.logPrint("!- " + DataManager.connectedPlayersDictionary[playerId] + " was kicked: " + reason + " -!");
	rpc_id(playerId, "kickedFromServer", reason);
	yield(get_tree().create_timer(0.1),"timeout")
	network.disconnect_peer(playerId, true);



func refreshPlayerCountLabel():
	get_node("Ui/ConnectedPeersLabel").text = "Connected: " + str(DataManager.connectedPlayersDictionary.size()) + "/" + str(maxPlayers - 1);



func _notification(what : int) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit();

func _on_Close_pressed() -> void:
	_notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST);



remote func receiveTurnData(action : String, position : Vector2, playerName : String = "", radius : float = 0.1) -> void:
	DataManager.turnDictionary[playerName] = {"action" : action, "position" : position, "radius" : radius};

func _on_TurnCooldown_timeout() -> void:
	turn = !turn;
	rpc_id(0, "turnSwitch", turn);
	if turn == false:
		var generalRange : int = 384;
		var worldState : Dictionary = {};
		var registeredShots : Dictionary = {};
		for p in DataManager.connectedPlayersDictionary:
			var playerName : String = DataManager.connectedPlayersDictionary[p];
			var currentPosition : Vector2 = Vector2(DataManager.playersDatasDictionary[playerName].posX, DataManager.playersDatasDictionary[playerName].posY);
			worldState[p] = {"playerName" : playerName, "posX" : currentPosition.x, "posY" : currentPosition.y};
			if DataManager.turnDictionary.has(playerName):
				if DataManager.turnDictionary[playerName].action == "move":
					if currentPosition.distance_to(DataManager.turnDictionary[playerName].position) < generalRange * DataManager.shipsDictionary[DataManager.playerShipsStatsDictionary[playerName].ship].moveRange:
						DataManager.saveDatasOfAPlayer(playerName, DataManager.turnDictionary[playerName].position);
						worldState[p].posX = DataManager.turnDictionary[playerName].position.x;
						worldState[p].posY = DataManager.turnDictionary[playerName].position.y;
				elif DataManager.turnDictionary[playerName].action =="shoot":
					var shotRadius : float = DataManager.turnDictionary[playerName].radius;
					if currentPosition.distance_to(DataManager.turnDictionary[playerName].position) < generalRange * DataManager.shipsDictionary[DataManager.playerShipsStatsDictionary[playerName].ship].shootRange:
						if shotRadius < DataManager.shipsDictionary[DataManager.playerShipsStatsDictionary[playerName].ship].maxRadius and shotRadius > DataManager.shipsDictionary[DataManager.playerShipsStatsDictionary[playerName].ship].minRadius:
							registeredShots[playerName] = {"position" : Vector2(DataManager.turnDictionary[playerName].position.x, DataManager.turnDictionary[playerName].position.y), "radius" : shotRadius};
		for s in registeredShots:
			var targets : Dictionary = {};
			for p in DataManager.connectedPlayersDictionary:
				if registeredShots[s].position.distance_to(Vector2(DataManager.playersDatasDictionary[DataManager.connectedPlayersDictionary[p]].posX, DataManager.playersDatasDictionary[DataManager.connectedPlayersDictionary[p]].posY)) < generalRange * registeredShots[s].radius:
					targets[DataManager.connectedPlayersDictionary[p]] = DataManager.shipsDictionary[DataManager.playerShipsStatsDictionary[s].ship].damage - (registeredShots[s].radius * DataManager.shipsDictionary[DataManager.playerShipsStatsDictionary[s].ship].damage);
			#rpc_id(0, "shootOnPos", registeredShots[s], registeredShots[s].position, registeredShots[s].radius, targets);
		rpc_id(0, "receiveWorldState", worldState);
		DataManager.turnDictionary = {};
