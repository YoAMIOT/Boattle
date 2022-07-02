extends Node

var playersDataFile : String = "res://data/playersData.json";
var playersDatas;
var connectedPlayersDictionnary : Dictionary;

func _ready():
	loadPlayersDatas();



func savePlayersDatas():
	var file : File = File.new();
	var error = file.open(playersDataFile, File.WRITE);
	printError(error);
	file.store_line(to_json(playersDatas));
	file.close()

func loadPlayersDatas():
	var file : File = File.new();
	if not file.file_exists(playersDataFile):
		savePlayersDatas();
		return;
	var error = file.open(playersDataFile, File.READ);
	printError(error);
	playersDatas = JSON.parse(file.get_as_text()).result;
	file.close();

func saveDatasOfAPlayer(playerName : String, position : Vector2):
	playersDatas[playerName] = {"posX" : position.x, "posY" : position.y}
	savePlayersDatas();



func playerConnected(playerId : int, playerName : String):
	connectedPlayersDictionnary[playerId] = playerName;

func playerDisconnected(playerId : int):
	connectedPlayersDictionnary.erase(playerId);



func printError(error):
	if error != 0:
		print("ERROR: ", error);
