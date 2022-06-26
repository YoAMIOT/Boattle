extends Control



func _on_PlayButton_pressed():
	get_node("Menu").visible = false;
	get_node("ServerMenu").visible = true;


func _on_QuitButton_pressed():
	get_tree().quit();


func _on_JoinButton_pressed():
	pass # Replace with function body.


func _on_BackButton_pressed():
	get_node("ServerMenu").visible = false;
	get_node("Menu").visible = true;
