extends KinematicBody2D

var playerName : String;

func move(newPosition : Vector2) -> void:
	self.position = newPosition;
