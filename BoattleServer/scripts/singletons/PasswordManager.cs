using Godot;
using System;

public class PasswordManager: Node {
    public Godot.Collections.Dictionary wrongPasswordDictionary;

    public void validatePassword(bool registration, string password, string playerName) {}

    private string generateSalt(){
        return "";
    }

    private string generateHashedPassword(string password, string salt) {
        return "";
    }
}