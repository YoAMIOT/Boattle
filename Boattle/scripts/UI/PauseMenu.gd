extends Control

func _on_ResumeButton_pressed() -> void:
	self.visible = false;

func _on_OptionsButton_pressed() -> void:
	get_node("MainPauseMenu").visible = false;
	get_node("OptionsMenu").refresh();
	get_node("OptionsMenu").visible = true;

func backOptions():
	get_node("OptionsMenu").visible = false;
	get_node("MainPauseMenu").visible = true;

func _on_LeaveButton_pressed() -> void:
	Server.disconnectFromServer();
