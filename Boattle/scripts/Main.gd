extends Node2D

var ClientBoat : PackedScene = preload("res://scenes/entities/Boat.tscn");
var PuppetBoat : PackedScene = preload("res://scenes/entities/Puppet.tscn");
var ShotRadius : PackedScene = preload("res://scenes/entities/ShotRadius.tscn");

func spawnClientPlayer(spawnPosition : Vector2, playerShipsDatas : Dictionary, currentHealth : int) -> void:
	var instance = ClientBoat.instance();
	self.add_child(instance);
	instance.position = spawnPosition;
	instance.setViewRangeMultiplier(playerShipsDatas["viewRange"]);
	instance.setShootRangeMultiplier(playerShipsDatas["shootRange"]);
	instance.setMoveRangeMultiplier(playerShipsDatas["moveRange"]);
	instance.setShootRadiusMultiplier(playerShipsDatas["minRadius"], playerShipsDatas["maxRadius"]);
	instance.setMaxHealth(playerShipsDatas["maxHealth"]);
	instance.setHealth(currentHealth)



func spawnPuppet(playerId : int, playerName : String, puppetPosition : Vector2, maxHealth : int, health : int) -> void:
	if get_tree().get_network_unique_id() == playerId:
		pass;
	else:
		if not get_node("Players").has_node(str(playerId)):
			var instance = PuppetBoat.instance();
			instance.position = puppetPosition;
			instance.name = str(playerId);
			instance.get_node("NameLabel").text = playerName;
			instance.setStats(maxHealth, health);
			get_node("Players").add_child(instance);

func killPuppet(playerId : int) -> void:
	yield(get_tree().create_timer(0.2), "timeout");
	if get_node("Players").has_node(str(playerId)):
		get_node("Players/" + str(playerId)).queue_free();



func shootOnPos(playerName : String, shotPosition : Vector2, radiusMultiplier : float, targets : Dictionary) -> void:
	var instance = ShotRadius.instance();
	get_node("Shots").add_child(instance);
	instance.name = playerName;
	instance.position = shotPosition;
	instance.scale = Vector2(radiusMultiplier, radiusMultiplier);
	if playerName == DataManager.datas["playerName"]:
		instance.color = Color(0, 1, 0, 0.6);
	for t in targets:
		if t == get_tree().get_network_unique_id():
			get_node("Boat").setHealth(targets[t]);
		else:
			if get_node("Players").has_node(str(t)):
				get_node("Players/" + str(t)).setHealth(targets[t]);
	yield(get_tree().create_timer(2), "timeout");
	instance.queue_free();
