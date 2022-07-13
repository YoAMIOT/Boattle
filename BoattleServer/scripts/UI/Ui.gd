extends Control

var selectedPlayerId : int;

func _on_ServerTabButton_toggled(pressed: bool) -> void:
	if pressed:
		get_node("ServerTabButton").disabled = true;
		get_node("PlayersTabButton").disabled = false;
		get_node("PlayersTabButton").pressed = false;
		get_node("PlayersTab").visible = false;

func _on_PlayersTabButton_toggled(pressed: bool) -> void:
	if pressed:
		get_node("PlayersTabButton").disabled = true;
		get_node("ServerTabButton").disabled = false;
		get_node("ServerTabButton").pressed = false;
		get_node("PlayersTab").visible = true;



func addPlayerToList(playerName : String) -> void:
	if not get_node("PlayersTab/PlayersList").items.has(playerName):
		get_node("PlayersTab/PlayersList").add_item(playerName);

func removePlayerFromList(playerName : String) -> void:
	for i in range(get_node("PlayersTab/PlayersList").get_item_count()):
		if get_node("PlayersTab/PlayersList").get_item_text(i) == playerName:
			get_node("PlayersTab/PlayersList").remove_item(i);



func _on_PlayersList_item_selected(index: int) -> void:
	get_node("PlayersTab/KickButton").disabled = false;
	var playerName : String = get_node("PlayersTab/PlayersList").get_item_text(index);
	var playerId : int = DataManager.getIdFromName(playerName);
	selectedPlayerId = playerId;
	var generalRange : int = 384;
	get_node("PlayersTab/PlayerNameLabel").text = "Player name: " + playerName;
	get_node("PlayersTab/PlayerIdLabel").text = "Connection ID: " + str(playerId);
	get_node("PlayersTab/PlayerViewRangeLabel").text = "View range: " + str(generalRange * DataManager.shipsDictionary[DataManager.playerShipsStatsDictionary[playerName].ship].viewRange);
	get_node("PlayersTab/PlayerMoveRangeLabel").text = "Move range: " + str(generalRange * DataManager.shipsDictionary[DataManager.playerShipsStatsDictionary[playerName].ship].moveRange);
	get_node("PlayersTab/PlayerShootRangeLabel").text = "Shoot range: " + str(generalRange * DataManager.shipsDictionary[DataManager.playerShipsStatsDictionary[playerName].ship].shootRange);



func _on_KickButton_pressed() -> void:
	get_node("PlayersTab/KickWindow").visible = true;

func _on_ValidateButton_pressed() -> void:
	if DataManager.connectedPlayersDictionary.has(selectedPlayerId):
		get_parent().kickPlayer(selectedPlayerId, get_node("PlayersTab/KickWindow/Reason").text);
	get_node("PlayersTab/KickWindow").visible = false;
	get_node("PlayersTab/KickWindow/Reason").text = "";

func _on_CancelButton_pressed() -> void:
	get_node("PlayersTab/KickWindow").visible = false;
	get_node("PlayersTab/KickWindow/Reason").text = "";
