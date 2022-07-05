extends Node2D

export var ClientBoat : PackedScene;
export var PuppetBoat : PackedScene;

func spawnClientPlayer(spawnPosition : Vector2) -> void:
	var instance = ClientBoat.instance();
	self.add_child(instance);
	instance.position = spawnPosition;



func spawnPuppet(playerId : int, playerName : String, puppetPosition : Vector2) -> void:
	if get_tree().get_network_unique_id() == playerId:
		pass;
	else:
		if not get_node("Players").has_node(str(playerId)):
			var instance = PuppetBoat.instance();
			instance.position = puppetPosition;
			instance.name = str(playerId);
			instance.get_node("NameLabel").text = playerName;
			get_node("Players").add_child(instance);

func killPuppet(playerId : int) -> void:
	yield(get_tree().create_timer(0.2), "timeout");
	if get_node("Players").has_node(str(playerId)):
		get_node("Players/" + str(playerId)).queue_free();
