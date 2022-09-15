extends Node

var playersDataFile : String = "res://data/playersData.json";
var playersPasswordFile : String = "res://data/playersPasswords.json"
var playersShipsStatsFile : String = "res://data/playersShipsStats.json"
var shipsFile : String = "res://data/ships.json"
var playersDatasDictionary : Dictionary;
var connectedPlayersDictionary : Dictionary;
var playersPasswordsDictionary : Dictionary;
var playerShipsStatsDictionary : Dictionary;
var shipsDictionary : Dictionary;
var turnDictionary : Dictionary;

func _ready() -> void:
	loadPlayersDatas();
	loadPlayersPasswords();
	loadShipsStats();
	loadPlayersShipsStats();



func savePlayersDatas() -> void:
	var file : File = File.new();
	var error = file.open(playersDataFile, File.WRITE);
	printError(error);
	file.store_line(to_json(playersDatasDictionary));
	file.close();

func loadPlayersDatas() -> void:
	var file : File = File.new();
	if not file.file_exists(playersDataFile):
		savePlayersDatas();
		return;
	var error = file.open(playersDataFile, File.READ);
	printError(error);
	if file.get_as_text() != "":
		playersDatasDictionary = JSON.parse(file.get_as_text()).result;
	file.close();

func saveDatasOfAPlayer(playerName : String, position : Vector2) -> void:
	playersDatasDictionary[playerName] = {"posX" : position.x, "posY" : position.y}
	savePlayersDatas();



func savePlayersPasswords():
	var file : File = File.new();
	var error = file.open(playersPasswordFile, File.WRITE);
	printError(error);
	file.store_line(to_json(playersPasswordsDictionary));
	file.close();

func loadPlayersPasswords():
	var file : File = File.new();
	if not file.file_exists(playersPasswordFile):
		savePlayersPasswords();
		return;
	var error = file.open(playersPasswordFile, File.READ);
	printError(error);
	if file.get_as_text() != "":
		playersPasswordsDictionary = JSON.parse(file.get_as_text()).result;
	file.close();

func savePasswordsForPlayer(password : String, salt : String, playerName : String) -> void:
	playersPasswordsDictionary[playerName] = {"password" : password, "salt" : salt};
	savePlayersPasswords();



func savePlayersShipsStats():
	var file : File = File.new();
	var error = file.open(playersShipsStatsFile, File.WRITE);
	printError(error);
	file.store_line(to_json(playerShipsStatsDictionary));
	file.close();

func loadPlayersShipsStats():
	var file : File = File.new();
	if not file.file_exists(playersShipsStatsFile):
		savePlayersShipsStats();
		return;
	var error = file.open(playersShipsStatsFile, File.READ);
	printError(error);
	if file.get_as_text() != "":
		playerShipsStatsDictionary = JSON.parse(file.get_as_text()).result;
	file.close();

func loadShipsStats():
	var file : File = File.new();
	var error = file.open(shipsFile, File.READ);
	printError(error);
	shipsDictionary = JSON.parse(file.get_as_text()).result;
	file.close();

func createShipStatsForPlayer(playerName : String):
	playerShipsStatsDictionary[playerName] = {"ship" : "default", "health" : 200};
	savePlayersShipsStats();

func saveShipsStatsForPlayer(playerName : String, ship : String) -> void:
	playerShipsStatsDictionary[playerName] = {"ship" : ship};
	savePlayersShipsStats();



func playerConnected(playerId : int, playerName : String) -> void:
	connectedPlayersDictionary[playerId] = playerName;
	get_node("/root/Server/Ui").addPlayerToList(playerName);

func playerDisconnected(playerId : int) -> void:
	if PasswordManager.wrongPasswordDictionary.has(connectedPlayersDictionary[playerId]):
		PasswordManager.wrongPasswordDictionary.erase(connectedPlayersDictionary[playerId]);
	get_node("/root/Server/Ui").removePlayerFromList(connectedPlayersDictionary[playerId]);
	connectedPlayersDictionary.erase(playerId);

func isPlayerConnected(playerName : String) -> bool:
	var connected : bool = false;
	for p in connectedPlayersDictionary:
		if connectedPlayersDictionary[p] == playerName:
			connected = true;
	return connected;



func getIdFromName(playerName : String) -> int:
	var playerId : int;
	for p in connectedPlayersDictionary:
		if connectedPlayersDictionary[p] == playerName:
			playerId = p;
	return playerId;



func printError(error) -> void:
	if error != 0:
		print("ERROR: ", error);
