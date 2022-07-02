extends Control

###Variables###
var regex : RegEx = RegEx.new();
var connectionSuccess : bool = false;



func _ready():
	fetchDataFromManager();
	var error = regex.compile("\\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\b");
	DataManager.printError(error);
	error = Server.connect("failedToConnect", self, "onConnectionFailed");
	DataManager.printError(error);
	error = Server.connect("successfullyConnected", self, "onConnectionSuccess");
	DataManager.printError(error);
	get_node("Menus/OptionsMenu/WindowSizeOption").disabled = DataManager.datas["fullscreen"];
	manageWindowSizeSelection();



func _on_PlayButton_pressed():
	get_node("Menus/Menu").visible = false;
	get_node("Menus/ServerMenu").visible = true;

func _on_QuitButton_pressed():
	get_tree().quit();

func _on_BackButton_pressed():
	get_node("Menus/ServerMenu").visible = false;
	get_node("Menus/Menu").visible = true;

func _on_OptionsButton_pressed():
	get_node("Menus/Menu").visible = false;
	get_node("Menus/OptionsMenu").visible = true;

func _on_BackOptionsButton_pressed():
	get_node("Menus/OptionsMenu").visible = false;
	get_node("Menus/Menu").visible = true;

func _on_CancelButton_pressed():
	_on_FailureTimer_timeout()

func _on_FullscreenSwitch_toggled(state : bool):
	OptionManager.setFullscreen(state);
	get_node("Menus/OptionsMenu/WindowSizeOption").disabled = state;

func _on_VSyncSwitch_toggled(state : bool):
	OptionManager.setVsync(state);

func _on_WindowSizeOption_item_selected(index : int):
	var selectedSize : String = get_node("Menus/OptionsMenu/WindowSizeOption").get_item_text(index);
	var firstInt : String = "";
	var secondInt : String = "";
	var size : Vector2;
	var i : int = 0;
	for c in selectedSize:
		i += 1;
		if i < 5:
			firstInt += c;
		elif i > 7:
			secondInt += c;
	size = Vector2(float(firstInt), float(secondInt));
	OptionManager.setWindowSize(size)



func _on_JoinButton_pressed():
	if get_node("Menus/ServerMenu/IpAddress").text.empty() == false:
		var result = regex.search(get_node("Menus/ServerMenu/IpAddress").text);
		if result:
			Server.ip = get_node("Menus/ServerMenu/IpAddress").text;
			Server.connectToServer();
			var serverName = get_node("Menus/ServerMenu/ServerName").text;
			var address = get_node("Menus/ServerMenu/IpAddress").text;
			DataManager.addToDictionnary(serverName,address);
			get_node("Menus/ServerMenu").visible = false;
			get_node("Menus/Connecting").visible = true;
			get_node("Menus/Connecting/TimeOutTimer").start();
			refreshServerList();



func onConnectionFailed():
	get_node("Menus/Connecting/ConnectingLabel").visible = false;
	get_node("Menus/Connecting/LoadingAnim").visible = false;
	get_node("Menus/Connecting/CancelButton").visible = false;
	get_node("Menus/Connecting/ConnectionFailedLabel").visible = true;
	get_node("Menus/Connecting/FailureTimer").start();

func onConnectionSuccess():
	get_node("Menus/Connecting/ConnectingLabel").visible = false;
	get_node("Menus/Connecting/LoadingAnim").visible = false;
	get_node("Menus/Connecting/CancelButton").visible = false;
	get_node("Menus/Connecting/ConnectedLabel").visible = true;
	connectionSuccess = true;
	get_node("Menus/Connecting/SuccessTimer").start();

func _on_TimeOutTimer_timeout():
	if connectionSuccess == false:
		get_node("Menus/Connecting/ConnectingLabel").visible = false;
		get_node("Menus/Connecting/LoadingAnim").visible = false;
		get_node("Menus/Connecting/ConnectionFailedLabel").visible = true;
		get_node("Menus/Connecting/CancelButton").visible = false;
		get_node("Menus/Connecting/FailureTimer").start();

func _on_FailureTimer_timeout():
	get_node("Menus/Connecting/ConnectingLabel").visible = true;
	get_node("Menus/Connecting/LoadingAnim").visible = true;
	get_node("Menus/Connecting/CancelButton").visible = true;
	get_node("Menus/Connecting/ConnectedLabel").visible = false;
	get_node("Menus/Connecting/ConnectionFailedLabel").visible = false;
	get_node("Menus/Connecting").visible = false;
	get_node("Menus/ServerMenu").visible = true;
	Server.resetNetworkPeer();

func _on_SuccessTimer_timeout():
	get_node("Menus").visible = false;
	get_node("Main").visible = true;



func _on_PlayerName_text_changed(newName : String):
	DataManager.savePlayerName(newName);

func _on_IpAddress_text_changed(enteredIpAddress : String):
	get_node("Menus/ServerMenu/Error").visible = false;
	get_node("Menus/ServerMenu/Error/EmptyAddress").visible = false;
	get_node("Menus/ServerMenu/Error/InvalidAddress").visible = false;
	get_node("Menus/ServerMenu/JoinButton").disabled = false;
	manageJoinButtonDisability();

	if enteredIpAddress != "":
		var result = regex.search(enteredIpAddress);
		if !result:
			get_node("Menus/ServerMenu/Error").visible = true;
			get_node("Menus/ServerMenu/Error/InvalidAddress").visible = true;
	else:
		get_node("Menus/ServerMenu/Error").visible = true;
		get_node("Menus/ServerMenu/Error/EmptyAddress").visible = true;

func _on_ServerName_text_changed(_new_text : String):
	manageJoinButtonDisability();

func manageJoinButtonDisability():
	if get_node("Menus/ServerMenu/ServerName").text.empty() or get_node("Menus/ServerMenu/IpAddress").text.empty():
		get_node("Menus/ServerMenu/JoinButton").disabled = true;
	elif get_node("Menus/ServerMenu/ServerName").text.empty() == false and get_node("Menus/ServerMenu/IpAddress").text.empty() == false:
		var result = regex.search(get_node("Menus/ServerMenu/IpAddress").text);
		if result:
			get_node("Menus/ServerMenu/JoinButton").disabled = false;
		else:
			get_node("Menus/ServerMenu/JoinButton").disabled = true;



func fetchDataFromManager():
	get_node("Menus/Menu/PlayerName").text = DataManager.datas["playerName"];
	get_node("Menus/OptionsMenu/FullscreenSwitch").pressed = DataManager.datas["fullscreen"];
	get_node("Menus/OptionsMenu/VSyncSwitch").pressed = DataManager.datas["vSync"];
	fillServerList();

func fillServerList():
	for s in DataManager.ipDictionnary:
		get_node("Menus/ServerMenu/ServerList").add_item(s);

func refreshServerList():
	get_node("Menus/ServerMenu/ServerList").clear();
	fillServerList();

func _on_ServerList_item_selected(index : int):
	var selectedServer : String = get_node("Menus/ServerMenu/ServerList").get_item_text(index);
	get_node("Menus/ServerMenu/ServerName").text = selectedServer;
	get_node("Menus/ServerMenu/IpAddress").text= DataManager.ipDictionnary.get(selectedServer);
	manageJoinButtonDisability();



func manageWindowSizeSelection():
	var size : Vector2 = DataManager.datas["windowSize"];
	var sizeStr : String = String(size.x) + " x " + String(size.y);
	for o in get_node("Menus/OptionsMenu/WindowSizeOption").get_item_count():
		if sizeStr == get_node("Menus/OptionsMenu/WindowSizeOption").get_item_text(o):
			get_node("Menus/OptionsMenu/WindowSizeOption").selected = o;
