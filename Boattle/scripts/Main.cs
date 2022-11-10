using Godot;
using System;

public class Main : Node2D{
    private PackedScene ClientBoat = ResourceLoader.Load<PackedScene>("res://scenes/entities/Boat.tscn");
    private PackedScene PuppetBoat = ResourceLoader.Load<PackedScene>("res://scenes/entities/Puppet.tscn");
    private PackedScene ShotRadius = ResourceLoader.Load<PackedScene>("res://scenes/entities/ShotRadius.tscn");

    public void spawnClientPlayer(Vector2 spawnPosition, Godot.Collections.Dictionary playerShipsDatas, int currentHealth){
        //fill
    }
}
