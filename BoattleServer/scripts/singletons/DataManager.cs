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

    private override void _Ready() {
        loadPlayerDatas();
        loadPlayersPasswords();
        loadShipsStats();
        loadPlayersShipsStats();
    }



    public void savePlayersDatas() {
        private File file = new File();
        file.Open(playersDataFile, File.WRITE);
        file.StoreLine(ToJson(playersDataDictionary));
        file.Close();
    }

    public void loadPlayerDatas() {
        private File file = new File();
        if (!file.FileExists(playersDataFile)) {
            savePlayersDatas();
            return;
        }
        file.Open(playersDataFile, File.READ);
        if (file.GetAsText() != "") {
            playersDataDictionary = JSON.Parse(file.GetAsText()).result;
            file.Close();
        }
    }

    public void saveDatasOfAPlayer(string playerName, Vector2 position) {
        playersDataDictionary[playerName] = {
            "posX": position.X,
            "posY": position.Y
        };
        savePlayersDatas;
    }



    public void savePlayersPasswords() {
        private File file = new File();
        file.Open(playersPasswordFile, File.WRITE);
        file.StoreLine(ToJson(playersPasswordsDictionary));
        file.Close()
    }

    public void loadPlayersPasswords() {
        private File file = new File();
        if (!file.FileExists(playersPasswordFile)) {
            savePlayersPasswords();
            return;
        }
        file.Open(playersPasswordFile, File.READ);
        if (file.GetAsText() != "") {
            playersPasswordsDictionary = JSON.Parse(file.GetAsText()).result;
        }
        file.Close();
    }

    public void savePasswordForAPlayer(string password, string salt, string playerName) {
        playersPasswordsDictionary[playerName] = {"password" : password, "salt" : salt};
        savePlayersPasswords();
    }



    public void savePlayersShipsStats() {
        private File file = new File();
        file.Open(playersShipsStatsFile, File.WRITE);
        file.StoreLine(ToJson(playersShipsStatsDictionary));
        file.Close();
    }

    public void loadPlayersShipsStats() {
        private File file = new File();
        if (!file.FileExists(playersShipsStatsFile)){
            savePlayersShipsStats();
            return;
        }
        file.Open(playersShipsStatsFile, READ);
        if (file.GetAsText() != ""){
            playersShipsStatsDictionary = JSON.Parse(file.GetAsText()).result;
        }
        file.Close();
    }

    public void saveShipsStatsForAPlayer(string playerName, string ship) {
        playersShipsStatsDictionary[playerName] = {"ship" : ship};
        savePlayersShipsStats();
    }

    public void loadShipsStats() {}
    public void createShipStatsForAPlayer(string playerName) {}



    public void playerConnected(int playerId, string playerName) {}

    public void playerDisconnected(int playerId) {}

    public bool isPlayerConnected(string playerName) {
        private bool connected = false;
        return connected;
    }



    public int getIdFromName(string playerName) {
        private int playerId;
        return playerId;
    }
}