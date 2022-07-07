extends Control

###Variables###
var regex : RegEx = RegEx.new();
var connectionSuccess : bool = false;



func _ready() -> void:
	fetchDataFromManager();
	var error = regex.compile("\\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\b");
	DataManager.printError(error);
	error = Server.connect("failedToConnect", self, "onConnectionFailed");
	DataManager.printError(error);
	error = Server.connect("successfullyConnected", self, "onConnectionSuccess");
	DataManager.printError(error);



func resetMenus() -> void:
	connectionSuccess = false;
	_on_FailureTimer_timeout();
	get_node("Menus/Connecting/TimeOutTimer").stop();
	get_node("Menus/Connecting/TimeOutTimer").wait_time = 30;
	get_node("Menus/ServerMenu").visible = false;
	get_node("Menus/OptionsMenu").visible = false;
	get_node("PasswordPage").reset();
	get_node("PasswordPage"). visible = false;
	get_node("Menus").visible = true;
	get_node("Menus/Menu").visible = true;

func _on_PlayButton_pressed() -> void:
	get_node("Menus/Menu").visible = false;
	get_node("Menus/ServerMenu").visible = true;

func _on_QuitButton_pressed() -> void:
	get_tree().quit();

func _on_BackButton_pressed() -> void:
	get_node("Menus/ServerMenu").visible = false;
	get_node("Menus/Menu").visible = true;

func _on_OptionsButton_pressed() -> void:
	get_node("Menus/Menu").visible = false;
	get_node("Menus/OptionsMenu").refresh();
	get_node("Menus/OptionsMenu").visible = true;

func backOptions() -> void:
	get_node("Menus/OptionsMenu").visible = false;
	get_node("Menus/Menu").visible = true;

func _on_CancelButton_pressed() -> void:
	_on_FailureTimer_timeout()



func _on_JoinButton_pressed() -> void:
	if not get_node("Menus/ServerMenu/IpAddress").text.empty():
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



func onConnectionFailed() -> void:
	get_node("Menus/Connecting/ConnectingLabel").visible = false;
	get_node("Menus/Connecting/LoadingAnim").visible = false;
	get_node("Menus/Connecting/CancelButton").visible = false;
	get_node("Menus/Connecting/ConnectionFailedLabel").visible = true;
	get_node("Menus/Connecting/FailureTimer").start();

func onConnectionSuccess() -> void:
	get_node("Menus/Connecting/ConnectingLabel").visible = false;
	get_node("Menus/Connecting/LoadingAnim").visible = false;
	get_node("Menus/Connecting/CancelButton").visible = false;
	get_node("Menus/Connecting/ConnectedLabel").visible = true;
	connectionSuccess = true;

func _on_TimeOutTimer_timeout() -> void:
	if not connectionSuccess:
		get_node("Menus/Connecting/ConnectingLabel").visible = false;
		get_node("Menus/Connecting/LoadingAnim").visible = false;
		get_node("Menus/Connecting/ConnectionFailedLabel").visible = true;
		get_node("Menus/Connecting/CancelButton").visible = false;
		get_node("Menus/Connecting/FailureTimer").start();

func _on_FailureTimer_timeout() -> void:
	get_node("Menus/Connecting/ConnectingLabel").visible = true;
	get_node("Menus/Connecting/LoadingAnim").visible = true;
	get_node("Menus/Connecting/CancelButton").visible = true;
	get_node("Menus/Connecting/ConnectedLabel").visible = false;
	get_node("Menus/Connecting/ConnectionFailedLabel").visible = false;
	get_node("Menus/Connecting").visible = false;
	get_node("Menus/ServerMenu").visible = true;
	Server.resetNetworkPeer();

func enterGame() -> void:
	get_node("Menus").visible = false;
	get_node("Main").visible = true;



func _on_PlayerName_text_changed(newName : String) -> void:
	if get_node("Menus/Menu/PlayerName").text == "":
		get_node("Menus/Menu/PlayButton").disabled = true;
	else:
		get_node("Menus/Menu/PlayButton").disabled = false;
	DataManager.savePlayerName(newName);

func _on_IpAddress_text_changed(enteredIpAddress : String) -> void:
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

func _on_ServerName_text_changed(_new_text : String) -> void:
	manageJoinButtonDisability();

func manageJoinButtonDisability() -> void:
	if get_node("Menus/ServerMenu/ServerName").text.empty() or get_node("Menus/ServerMenu/IpAddress").text.empty():
		get_node("Menus/ServerMenu/JoinButton").disabled = true;
	elif not get_node("Menus/ServerMenu/ServerName").text.empty() and not get_node("Menus/ServerMenu/IpAddress").text.empty():
		var result = regex.search(get_node("Menus/ServerMenu/IpAddress").text);
		if result:
			get_node("Menus/ServerMenu/JoinButton").disabled = false;
		else:
			get_node("Menus/ServerMenu/JoinButton").disabled = true;



func fetchDataFromManager() -> void:
	get_node("Menus/Menu/PlayerName").text = DataManager.datas["playerName"];
	fillServerList();

func fillServerList() -> void:
	for s in DataManager.ipDictionnary:
		get_node("Menus/ServerMenu/ServerList").add_item(s);

func refreshServerList() -> void:
	get_node("Menus/ServerMenu/ServerList").clear();
	fillServerList();

func _on_ServerList_item_selected(index : int) -> void:
	var selectedServer : String = get_node("Menus/ServerMenu/ServerList").get_item_text(index);
	get_node("Menus/ServerMenu/ServerName").text = selectedServer;
	get_node("Menus/ServerMenu/IpAddress").text = DataManager.ipDictionnary.get(selectedServer);
	_on_IpAddress_text_changed(DataManager.ipDictionnary.get(selectedServer));
	manageJoinButtonDisability();



func showKickMessage(reason : String) -> void:
	get_node("Menus/KickedPopup/Label").text = reason;
	get_node("Menus/KickedPopup").popup();

func _on_KickedPopup_popup_hide() -> void:
	get_node("Menus/KickedPopup/Label").text = "";
