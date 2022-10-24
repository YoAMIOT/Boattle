using Godot;
using System;

public class Puppet : KinematicBody2D{

    private int health;
    private int maxHealth;

    public void move(Vector2 newPosition){
        this.Position = newPosition;
    }

    public void setHealth(int newHealth){
        this.health = newHealth;
    }

    public void setStats(int newMaxHealth, int newHealth){
        this.maxHealth = newMaxHealth;
        this.GetNode<ProgressBar>("ProgressBar").MaxValue = maxHealth;
        setHealth(newHealth);
    }
}
