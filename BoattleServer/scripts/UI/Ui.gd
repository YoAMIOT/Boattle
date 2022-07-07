extends Control

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
