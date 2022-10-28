using Godot;
using System;

public class PasswordManager: Node {
    public Godot.Collections.Dictionary wrongPasswordDictionary;

    public void validatePassword(bool registration, string password, string playerName) {}

    private string generateSalt(){
        GD.Randomize();
        string salt = GD.Randi().SHA256Text();
        return salt;
    }

    private string generateHashedPassword(string password, string salt) {
        return "";
    }
}