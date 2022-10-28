using Godot;
using System;

public class PasswordManager: Node {
    public Godot.Collections.Dictionary wrongPasswordDictionary;
    private DataManager DataManager;
    private Server Server;

    public override void _Ready(){
        DataManager = this.GetNode<DataManager>("/root/DataManager");
        Server = this.GetNode<Server>("/root/Server");
    }

    public void validatePassword(bool registration, string password, string playerName) {
        int playerId = DataManager.getIdFromName(playerName);
        if (registration){
            string salt = generateSalt();
            string hashedPassword = generateHashedPassword(password, salt);
            DataManager.savePasswordForAPlayer(hashedPassword, salt, playerName);
            validatePassword(false, password, playerName);
        } else if (!registration){
            string retrievedSalt = DataManager.playersPasswordsDictionary[playerName].salt;
            string hashedPassword = generateHashedPassword(password, retrievedSalt);
            if (!hashedPassword == DataManager.playersPasswordsDictionary[playerName].password){
                Server.wrongPasswordEntered(playerId);
                if (wrongPasswordDictionary.Contains(playerName)){
                    wrongPasswordDictionary[playerName] += 1;
                    if (wrongPasswordDictionary[playerName] == 3){
                        Server.kickPlayer(playerId, "You entered 3 wrong passwords");
                        wrongPasswordDictionary.Remove(playerName);
                    }
                } else {
                    wrongPasswordDictionary[playerName] = 1;
                }
            }
        }
    }

    private string generateSalt() {
        GD.Randomize();
        string salt = GD.Randi().SHA256Text();
        return salt;
    }

    private string generateHashedPassword(string password, string salt) {
        int rounds = Math.Pow(2, 18);
        while (rounds > 0){
            password = (password + salt).SHA256Text();
            rounds -= 1;
        }
        return password;
    }
}