using Godot;
using System;

public class PasswordManager: Node {
    Godot.Collections.Dictionary wrongPasswordDictionary = {};

    public void validatePassword(bool registration, string password, string playerName) {}

    private string generateSalt() {}

    private string generateHashedPassword(string password, string salt) {}
}