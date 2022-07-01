extends Node

var playersDataFile : String = "res://data/playersData.json";
var playersDatas;

func _ready():
	loadPlayersDatas();



func savePlayersDatas():
	var file : File = File.new();
	var error = file.open(playersDataFile, File.WRITE);
	DataManager.printError(error);
	file.store_line(to_json(playersDatas));
	file.close()

func loadPlayersDatas():
	var file : File = File.new();
	if not file.file_exists(playersDataFile):
		savePlayersDatas();
		return;
	var error = file.open(playersDataFile, File.READ);
	DataManager.printError(error);
	playersDatas = JSON.parse(file.get_as_text()).result;
	file.close();

func checkIfPlayerExists(playerName : String)
	if not playersDatas.has(playerName):
		var position : Vector2 = Vector2(0 ,0);
		saveDatasOfAPlayer(playerName, position);

func saveDatasOfAPlayer(playerName : String, position : Vector2):
	playersDatas[playerName] = {"posX" : position.x, "posY" : position.y}
	savePlayersDatas();



func printError(error):
	if error != 0:
		print("ERROR: ", error);
