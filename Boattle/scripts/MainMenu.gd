extends Control

###Variables###
var regex : RegEx = RegEx.new();
var connectionSuccess : bool = false;



func _ready():
	regex.compile("\\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\b");
	var _signalFailedConnect = Server.connect("failedToConnect", self, "onConnectionFailed");
	var _signalSuccessConnect = Server.connect("successfullyConnected", self, "onConnectionSuccess");


func _on_PlayButton_pressed():
	get_node("Menu").visible = false;
	get_node("ServerMenu").visible = true;

func _on_QuitButton_pressed():
	get_tree().quit();

func _on_BackButton_pressed():
	get_node("ServerMenu").visible = false;
	get_node("Menu").visible = true;



func _on_JoinButton_pressed():
	get_node("ServerMenu/Error").visible = false;
	get_node("ServerMenu/Error/EmptyAddress").visible = false;
	get_node("ServerMenu/Error/InvalidAddress").visible = false;

	if get_node("ServerMenu/IpAddress").text.empty() == false:
		var result = regex.search(get_node("ServerMenu/IpAddress").text);
		if result:
			Server.ip = get_node("ServerMenu/IpAddress").text;
			Server.connectToServer();
			get_node("ServerMenu").visible = false;
			get_node("Connecting").visible = true;
			get_node("Connecting/TimeOutTimer").start();
		else:
			get_node("ServerMenu/Error").visible = true;
			get_node("ServerMenu/Error/InvalidAddress").visible = true;
	elif get_node("ServerMenu/IpAddress").text.empty() == true:
		get_node("ServerMenu/Error").visible = true;
		get_node("ServerMenu/Error/EmptyAddress").visible = true;


func onConnectionFailed():
	get_node("Connecting/ConnectingLabel").visible = false;
	get_node("Connecting/LoadingAnim").visible = false;
	get_node("Connecting/ConnectionFailedLabel").visible = true;
	get_node("Connecting/FailureTimer").start();

func onConnectionSuccess():
	get_node("Connecting/ConnectingLabel").visible = false;
	get_node("Connecting/LoadingAnim").visible = false;
	get_node("Connecting/ConnectedLabel").visible = true;
	connectionSuccess = true;
	get_node("Connecting/SuccessTimer").start();

func _on_TimeOutTimer_timeout():
	if connectionSuccess == false:
		get_node("Connecting/ConnectingLabel").visible = false;
		get_node("Connecting/LoadingAnim").visible = false;
		get_node("Connecting/ConnectionFailedLabel").visible = true;
		get_node("Connecting/FailureTimer").start();

func _on_FailureTimer_timeout():
	get_node("Connecting/ConnectingLabel").visible = true;
	get_node("Connecting/LoadingAnim").visible = true;
	get_node("Connecting/ConnectedLabel").visible = false;
	get_node("Connecting/ConnectionFailedLabel").visible = false;
	get_node("Connecting").visible = false;
	get_node("ServerMenu").visible = true;
	Server.resetNetworkPeer();

func _on_SuccessTimer_timeout():
	get_tree().change_scene("res://scenes/Test.tscn");



func _on_LineEdit_text_changed(playerName):
	Server.playerName = playerName;
	print(Server.playerName);
