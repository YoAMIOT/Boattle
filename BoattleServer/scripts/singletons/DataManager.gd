extends Node

var playersDataFile : String = "res://data/playersData.json";
var playersData;

func _ready():
	var file : File = File.new(); 
	file.open(playersDataFile, File.READ);
	var datasJson = JSON.parse(file.get_as_text());
	file.close();
	playersData = datasJson.result;
