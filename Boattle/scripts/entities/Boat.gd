extends KinematicBody2D

var turn : bool = true;
var turnMode : String = "move";
var viewRangeMultiplier : float = 1;
var moveRangeMultiplier : float = 1;
var shootRangeMultiplier : float = 1;
var minShootRadius : float = 1;
var maxShootRadius : float = 1;
var currentRadius : float = 1;
const SROLL_STEP : float = 0.05;
const RANGE : int = 384;
var maxHealth : int;
var health : int;



func _physics_process(_delta) -> void:
	if get_node("UI/PauseMenu").visible == false:
		if Input.is_action_just_pressed("mouse_left") and turn:
			if turnMode == "move" and self.position.distance_to(get_global_mouse_position()) < RANGE * moveRangeMultiplier:
				get_node("Pointer/MovePointer").global_position = get_global_mouse_position();
				get_node("Pointer/ShootPointerStatic").visible = false;
				get_node("Pointer/MovePointer").visible = true;
				Server.sendTurnDataToServer(turnMode, get_global_mouse_position());
			if turnMode == "shoot" and self.position.distance_to(get_global_mouse_position()) < RANGE * shootRangeMultiplier:
				get_node("Pointer/MovePointer").visible = false;
				get_node("Pointer/ShootPointerStatic").global_position = get_global_mouse_position();
				get_node("Pointer/ShootPointerStatic").scale = Vector2(currentRadius, currentRadius);
				get_node("Pointer/ShootPointerStatic").visible = true;
				Server.sendTurnDataToServer(turnMode, get_global_mouse_position(), currentRadius);
		if turnMode == "shoot":
			if Input.is_action_just_released("scrollUp") and currentRadius < maxShootRadius - 0.01:
				currentRadius += SROLL_STEP;
				get_node("Pointer/ShootPointer").scale = Vector2(currentRadius, currentRadius);
			elif Input.is_action_just_released("scrollDown") and currentRadius > minShootRadius + 0.01:
				currentRadius -= SROLL_STEP;
				get_node("Pointer/ShootPointer").scale = Vector2(currentRadius, currentRadius);
			if self.position.distance_to(get_global_mouse_position()) < RANGE * shootRangeMultiplier:
				get_node("Pointer/ShootPointer").global_position = get_global_mouse_position();
		if Input.is_action_just_pressed("1"):
			var pressed : bool = true;
			_on_MoveButton_toggled(pressed);
		if Input.is_action_just_pressed("2"):
			var pressed : bool = true;
			_on_ShootButton_toggled(pressed);
	if Input.is_action_just_pressed("pause"):
		if get_node("UI/PauseMenu").visible == false:
			get_node("UI/GameUI").visible = false;
			get_node("UI/PauseMenu").visible = true;
		elif get_node("UI/PauseMenu").visible == true:
			if get_node("UI/PauseMenu/OptionsMenu").visible == false:
				get_node("UI/PauseMenu").visible = false;
				get_node("UI/GameUI").visible = true;
			elif get_node("UI/PauseMenu/OptionsMenu").visible == true:
				get_node("UI/PauseMenu").backOptions();



func moveClientBoat(newPosition : Vector2) -> void:
	self.position = newPosition;



func _on_MoveButton_toggled(pressed: bool) -> void:
	if pressed == true:
		get_node("UI/GameUI/MoveButton").pressed = pressed;
		get_node("UI/GameUI/MoveButton").disabled = pressed;
		get_node("UI/GameUI/ShootButton").disabled = !pressed;
		get_node("UI/GameUI/ShootButton").pressed = !pressed;
		get_node("Ranges/MoveRange").visible = pressed;
		get_node("Ranges/ShootRange").visible = !pressed;
		get_node("Pointer/ShootPointer").visible = !pressed;
		turnMode = "move";

func _on_ShootButton_toggled(pressed: bool) -> void:
	if pressed == true:
		get_node("UI/GameUI/ShootButton").pressed = pressed;
		get_node("UI/GameUI/ShootButton").disabled = pressed;
		get_node("UI/GameUI/MoveButton").disabled = !pressed;
		get_node("UI/GameUI/MoveButton").pressed = !pressed;
		get_node("Ranges/ShootRange").visible = pressed;
		get_node("Ranges/MoveRange").visible = !pressed;
		get_node("Pointer/ShootPointer").visible = pressed;
		turnMode = "shoot";



func setViewRangeMultiplier(newRange : float) -> void:
	viewRangeMultiplier = newRange;
	get_node("UI").rect_scale = Vector2(viewRangeMultiplier, viewRangeMultiplier);
	get_node("Camera").zoom = Vector2(viewRangeMultiplier, viewRangeMultiplier);

func setShootRangeMultiplier(newRange : float) -> void:
	shootRangeMultiplier = newRange;
	get_node("Ranges/ShootRange").scale = Vector2(shootRangeMultiplier, shootRangeMultiplier);

func setMoveRangeMultiplier(newRange : float) -> void:
	moveRangeMultiplier = newRange;
	get_node("Ranges/MoveRange").scale = Vector2(moveRangeMultiplier, moveRangeMultiplier);

func setShootRadiusMultiplier(minRadius : float, maxRadius : float) -> void:
	minShootRadius = minRadius;
	maxShootRadius = maxRadius;
	currentRadius = minRadius;
	get_node("Pointer/ShootPointer").scale = Vector2(minShootRadius, minShootRadius);
	get_node("Pointer/ShootPointerStatic").scale = Vector2(minShootRadius, minShootRadius);

func setMaxHealth(newMaxHealth : int) -> void:
	maxHealth = newMaxHealth;

func setHealth(newHealth : int) -> void:
	health = newHealth;




func setTurn(turnState : bool) -> void:
	turn = turnState;
	if turn:
		get_node("Ranges").visible = true;
		get_node("Pointer").visible = true;
	elif not turn:
		get_node("Pointer/MovePointer").visible = false;
		get_node("Pointer/ShootPointerStatic").visible = false;
		get_node("Pointer").visible = false;
		get_node("Ranges").visible = false;
