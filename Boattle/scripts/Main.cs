using Godot;
using System;

public class Main : Node2D{
    private PackedScene ClientBoat = ResourceLoader.Load<PackedScene>("res://scenes/entities/Boat.tscn");
    private PackedScene PuppetBoat = ResourceLoader.Load<PackedScene>("res://scenes/entities/Puppet.tscn");
    private PackedScene ShotRadius = ResourceLoader.Load<PackedScene>("res://scenes/entities/ShotRadius.tscn");
    private DataManager DataManager;

    public override void _Ready(){
        DataManager = this.GetNode<DataManager>("/root/DataManager");
    }

    public void spawnClientPlayer(Vector2 spawnPosition, Godot.Collections.Dictionary playerShipsDatas, int currentHealth){
        KinematicBody2D instance = (KinematicBody2D)ClientBoat.Instance();
        this.AddChild(instance);
        instance.Position = spawnPosition;
        instance.setViewRangeMultiplier((float)playerShipsDatas["viewRange"]);
        instance.setShootRangeMultiplier((float)playerShipsDatas["shootRange"]);
        instance.setMoveRangerMultiplier((float)playerShipsDatas["moveRange"]);
        instance.setShootRadiusMultiplier((float)playerShipsDatas["minRadius"], (float)playerShipsDatas["maxRadius"]);
        instance.setMaxHealth((int)playerShipsDatas["maxHealth"]);
        instance.setHealth(currentHealth);
    }

    public void spawnPuppet(int playerId, string playerName, Vector2 puppetPosition, int maxHealth, int health){
        if (GetTree().GetNetworkUniqueId() != playerId && !GetNode<Node2D>("Players").HasNode(playerId.ToString())){
            KinematicBody2D instance = (KinematicBody2D)PuppetBoat.Instance();
            GetNode<Node2D>("Players").AddChild(instance);
            instance.Position = puppetPosition;
            instance.Name = playerId.ToString();
            instance.GetNode<Label>("NameLabel").Text = playerName;
            instance.setStats(maxHealth, health);
        }
    }

    public async void killPuppet(int playerId){
        Timer Timer = new Timer();
        Timer.Autostart = true;
        Timer.WaitTime = 0.2F;
        Timer.OneShot = true;
        this.AddChild(Timer);
        await ToSignal(Timer, "timeout");
        Timer.QueueFree();
        if (GetNode<Node2D>("Players").HasNode(playerId.ToString())){
            GetNode<Node2D>("Players/" + playerId.ToString()).QueueFree();
        }
    }

    public async void shootOnPos(string playerName, Vector2 shotPosition, float radiusMultiplier, Godot.Collections.Dictionary targets){
        Polygon2D instance = (Polygon2D)ShotRadius.Instance();
        GetNode<Node2D>("Shots").AddChild(instance);
        instance.Name = playerName;
        instance.Position = shotPosition;
        instance.Scale = Vector2(radiusMultiplier, radiusMultiplier);
        if (playerName == (string)DataManager.datas["playerName"]){
            instance.Color = new Color(0, 1, 0, 0.6F);
        }
        foreach (int t in targets.Keys){
            if (t == GetTree().GetNetworkUniqueId()){
                GetNode<KinematicBody2D>("Boat").setHealth(targets[t]);
            } else if (GetNode<Node2D>("Players").HasNode(t.ToString())){
                GetNode<Node2D>("Players/" + t.ToString()).setHealth(targets[t]);
            }
        }
        Timer Timer = new Timer();
        Timer.Autostart = true;
        Timer.WaitTime = 2;
        Timer.OneShot = true;
        this.AddChild(Timer);
        await ToSignal(Timer, "timeout");
        Timer.QueueFree();
        instance.QueueFree();
    }
}
