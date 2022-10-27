using Godot;
using System;

public class DataManager: Node {
    private string playersDatasFile = "res://data/playersData.json";
    private string playersPasswordsFile = "res://data/playersPasswords.json";
    private string playersShipsStatsFile = "res://data/playersShipsStats.json";
    private string shipsFile = "res://data/ships.json";
    public Godot.Collections.Dictionary playersDatasDictionary = new Godot.Collections.Dictionary();
    public Godot.Collections.Dictionary connectedPlayersDictionary = new Godot.Collections.Dictionary();
    public Godot.Collections.Dictionary playersPasswordsDictionary = new Godot.Collections.Dictionary();
    public Godot.Collections.Dictionary playersShipsStatsDictionary = new Godot.Collections.Dictionary();
    public Godot.Collections.Dictionary shipsDictionary = new Godot.Collections.Dictionary();
    public Godot.Collections.Dictionary turnDictionary = new Godot.Collections.Dictionary();
    private PasswordManager PasswordManager;

    public override void _Ready(){
        loadPlayersDatas();
        loadPlayersPasswords();
        loadShipsStats();
        loadPlayersShipsStats();
        PasswordManager = GetNode<PasswordManager>("/root/PasswordManager");
    }

    public void savePlayersDatas(){
        File file = new File();
        file.Open(playersDatasFile, File.ModeFlags.Write);
        file.StoreLine(JSON.Print(playersDatasDictionary));
        file.Close();
    }

    public void loadPlayersDatas() {
        File file = new File();
        if (!file.FileExists(playersDatasFile)) {
            savePlayersDatas();
            return;
        }
        file.Open(playersDatasFile, File.ModeFlags.Read);
        if (file.GetAsText() != "") {
            playersDatasDictionary = (Godot.Collections.Dictionary)JSON.Parse(file.GetAsText()).Result;
            file.Close();
        }
    }

    public void saveDatasOfAPlayer(string playerName, Vector2 position) {
        playersDatasDictionary[playerName] = new Godot.Collections.Dictionary(){
            {"posX", position.x},
            {"posY", position.y}
        };
        savePlayersDatas();
    }



    public void savePlayersPasswords() {
        File file = new File();
        file.Open(playersPasswordsFile, File.ModeFlags.Write);
        file.StoreLine(JSON.Print(playersPasswordsDictionary));
        file.Close();
    }

    public void loadPlayersPasswords() {
        File file = new File();
        if (!file.FileExists(playersPasswordsFile)) {
            savePlayersPasswords();
            return;
        }
        file.Open(playersPasswordsFile, File.ModeFlags.Read);
        if (file.GetAsText() != "") {
            playersPasswordsDictionary = (Godot.Collections.Dictionary)JSON.Parse(file.GetAsText()).Result;
        }
        file.Close();
    }

    public void savePasswordForAPlayer(string password, string salt, string playerName) {
        playersPasswordsDictionary[playerName] = new Godot.Collections.Dictionary(){
            {"password", password},
            {"salt", salt}
        };
        savePlayersPasswords();
    }



    public void savePlayersShipsStats() {
        File file = new File();
        file.Open(playersShipsStatsFile, File.ModeFlags.Write);
        file.StoreLine(JSON.Print(playersShipsStatsDictionary));
        file.Close();
    }

    public void loadPlayersShipsStats() {
        File file = new File();
        if (!file.FileExists(playersShipsStatsFile)) {
            savePlayersShipsStats();
            return;
        }
        file.Open(playersShipsStatsFile, File.ModeFlags.Read);
        if (file.GetAsText() != "") {
            playersShipsStatsDictionary = (Godot.Collections.Dictionary)JSON.Parse(file.GetAsText()).Result;
        }
        file.Close();
    }

    public void saveShipsStatsForAPlayer(string playerName, string ship) {
        playersShipsStatsDictionary[playerName] = new Godot.Collections.Dictionary(){
            {"ship" , ship}
        };
        savePlayersShipsStats();
    }

    public void loadShipsStats() {
        File file = new File();
        file.Open(shipsFile, File.ModeFlags.Read);
        shipsDictionary = (Godot.Collections.Dictionary)JSON.Parse(file.GetAsText()).Result;
        file.Close();
    }
    
    public void createShipStatsForAPlayer(string playerName) {
        playersShipsStatsDictionary[playerName] = new Godot.Collections.Dictionary(){
            {"ship" , "default"},
            {"health" , 200}
        };
        savePlayersShipsStats();
    }



    public void playerConnected(int playerId, string playerName) {
        connectedPlayersDictionary[playerId] = playerName;
        this.GetNode<UI>("/root/Server/Ui").addPlayerToList(playerName);
    }

    public void playerDisconnected(int playerId) {
        if (PasswordManager.wrongPasswordDictionary.Contains(connectedPlayersDictionary[playerId])){
            PasswordManager.wrongPasswordDictionary.Remove(connectedPlayersDictionary[playerId]);
        }
        this.GetNode<UI>("/root/Server/Ui").removePlayerFromList(connectedPlayersDictionary[playerId].ToString());
        connectedPlayersDictionary.Remove(playerId);
    }

    public bool isPlayerConnected(string playerName) {
        bool connected = false;
        foreach (int i in connectedPlayersDictionary){
            if connectedPlayersDictionary[i] == playerName{
                connected = true;
            }
        }
        return connected;
    }



    public int getIdFromName(string playerName) {
        int playerId = 0;
        foreach (int i in connectedPlayersDictionary){
            if connectedPlayersDictionary[p] == playerName{
                playerId = p
            }
        }
        return playerId;
    }
}