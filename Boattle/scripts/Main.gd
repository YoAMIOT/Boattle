extends Node2D

export var ClientBoat : PackedScene;
export var PuppetBoat : PackedScene;
var lastWorldState : int = 0;
var worldStateBuffer : Array;
const INTERPOLATION_OFFSET : int = 100;

func instantiateClientBoat():
	var instance = ClientBoat.instance();
	get_node(".").add_child(instance);
	instance.position = Vector2(0,0);



func spawnPuppet(playerId, puppetPosition):
	if get_tree().get_network_unique_id() == playerId:
		pass;
	else:
		if not get_node("Players").has_node(str(playerId)):
			var instance = PuppetBoat.instance();
			instance.position = puppetPosition;
			instance.name = str(playerId);
			get_node("Players").add_child(instance);

func killPuppet(playerId):
	yield(get_tree().create_timer(0.2), "timeout");
	get_node("Players/" + str(playerId)).queue_free();
