using Godot;
using System;

public class PasswordManager: Node {
    public Godot.Collections.Dictionary wrongPasswordDictionary;

    public void validatePassword(bool registration, string password, string playerName) {}

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