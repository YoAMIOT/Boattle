using Godot;
using System;

public class Log : RichTextLabel{
    public void logPrint(string newLine){
        this.BbcodeText += "\n" + newLine;
    }
}
