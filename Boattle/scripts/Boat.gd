extends KinematicBody2D



func _physics_process(delta):
	if Input.is_action_just_pressed("mouse_left"):
		self.position = get_global_mouse_position();
