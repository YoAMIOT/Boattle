extends KinematicBody2D

var turn : bool = true;

func _physics_process(_delta) -> void:
	if get_node("UI/PauseMenu").visible == false:
		if Input.is_action_just_pressed("mouse_left") and turn:
			Server.sendPosToServer(get_global_mouse_position());
	if Input.is_action_just_pressed("pause"):
		if get_node("UI/PauseMenu").visible == false:
			get_node("UI/PauseMenu").visible = true;
		elif get_node("UI/PauseMenu").visible == true:
			if get_node("UI/PauseMenu/OptionsMenu").visible == false:
				get_node("UI/PauseMenu").visible = false;
			elif get_node("UI/PauseMenu/OptionsMenu").visible == true:
				get_node("UI/PauseMenu").backOptions();



func moveClientBoat(newPosition : Vector2) -> void:
	self.position = newPosition;



func _on_MoveButton_toggled(pressed: bool) -> void:
	get_node("UI/GameUI/MoveButton").pressed = pressed;
	get_node("UI/GameUI/ShootButton").pressed = !pressed;

func _on_ShootButton_toggled(pressed: bool) -> void:
	get_node("UI/GameUI/ShootButton").pressed = pressed;
	get_node("UI/GameUI/MoveButton").pressed = !pressed;
