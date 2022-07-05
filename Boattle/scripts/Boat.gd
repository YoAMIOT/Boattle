extends KinematicBody2D

var turn : bool = true;

func _physics_process(_delta) -> void:
	if Input.is_action_just_pressed("mouse_left") and turn:
		Server.sendPosToServer(get_global_mouse_position());


func moveClientBoat(newPosition : Vector2) -> void:
	self.position = newPosition;
