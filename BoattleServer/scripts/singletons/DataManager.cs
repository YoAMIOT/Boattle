using Godot;
using System;

public class DataManager: Node {
    private string playersDataFile = "res://data/playersData.json";
    private string playersPasswordFile = "res://data/playersPasswords.json";
    private string playersShipsStatsFile = "res://data/playersShipsStats.json";
    private string shipsFile = "res://data/ships.json";
    public Godot.Collections.Dictionary playersDataDictionary;
    public Godot.Collections.Dictionary connectedPlayersDictionary;
    public Godot.Collections.Dictionary playersPasswordsDictionary;
    public Godot.Collections.Dictionary playersShipsStatsDictionary;
    public Godot.Collections.Dictionary shipsDictionary;
    public Godot.Collections.Dictionary turnDictionary;
}