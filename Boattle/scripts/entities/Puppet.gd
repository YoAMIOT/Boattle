extends KinematicBody2D

var playerName : String;
var health : int;
var maxHealth : int;

func move(newPosition : Vector2) -> void:
	self.position = newPosition;

func setHealth(newHealth : int) -> void:
	self.health = newHealth;
	get_node("ProgressBar").value = health;

func setStats(newMaxHealth : int, newHealth : int) -> void:
	maxHealth = newMaxHealth;
	get_node("ProgressBar").max_value = maxHealth;
	setHealth(newHealth);
