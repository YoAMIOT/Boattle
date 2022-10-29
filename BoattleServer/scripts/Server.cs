using Godot;
using System;

public class Server : Node{
        private NetworkedMultiplayerENet Network = new NetworkedMultiplayerENet();
        private string ip = "Unknown Address";
        private int port = 4180;
        private int maxPlayers = 20;
        private UPNP UPNP = new UPNP();
        private bool serverStarted = false;
        private bool turn = false;
        private RichTextLabel Log;
        
    public override void _Ready(){
        Log = this.GetNode<RichTextLabel>("Ui/Log");
    }
}
