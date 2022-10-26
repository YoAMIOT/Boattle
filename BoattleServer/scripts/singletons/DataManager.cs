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

    private override void _Ready(){
        loadPlayerDatas();
        loadPlayersPasswords();
        loadShipsStats();
        loadPlayersShipsStats();
    }



    public void savePlayersDatas(){

    }

    public void loadPlayerDatas(){

    }

    public void saveDatasOfAPlayer(string playerName, Vector2 position){

    }



    public void savePlayersPasswords(){

    }

    public void loadPlayersPasswords(){

    }

    public void savePasswordForAPlayer(string password, string salt, string playerName){

    }



    public void savePlayersShipsStats(){

    }

    public void loadPlayersShipsStats(){

    }

    public void saveShipsStatsForAPlayer(string playerName, string ship){

    }

    public void loadShipsStats(){

    }
    public void createShipStatsForAPlayer(string playerName){

    }



    public void playerConnected(int playerId, string playerName){

    }

    public void playerDisconnected(int playerId){

    }

    public bool isPlayerConnected(string playerName){
        private bool connected = false;
        return connected;
    }



    public int getIdFromName(string playerName){
        private int playerId;
        return playerId;
    }



    public void printError(int error){
        if (error != 0){
            GD.Print("Error", error);
        }
    }
}