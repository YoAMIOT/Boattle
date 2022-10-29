using Godot;
using System;

public class Server: Node {
    private NetworkedMultiplayerENet Network = new NetworkedMultiplayerENet();
    private string ip = "Unknown Address";
    private int port = 4180;
    private int maxPlayers = 20;
    private UPNP UPNP = new UPNP();
    private bool serverStarted = false;
    private bool turn = false;
    private RichTextLabel Log;

    public override void _Ready() {
        Log = this.GetNode < RichTextLabel > ("Ui/Log");
        Os.SetWindowFullscreen(false);
        GetTree().SetAutoAcceptQuit(false);
        UPNP.Discover(2000, 2, "InternetGatewayDevice");
        ip = UPNP.QueryExternalAddress();
        UPNP.AddPortMapping(port, port, "BoattleServer", "UDP");
        UPNP.AddPortMapping(port, port, "BoattleServer", "TCP");
        this.GetNode<Label>("UI/IpLabel").Text = ip;
        
        #this.GetNode<Button>("").Connect("pressed", this, "ValidateButtonPressed");
        this.GetNode<Button>("Ui/StartServer").Connect("pressed", this, "StartServerPressed");
    }
    
    private void ValidateButtonPressed(){
        maxPlayers = this.GetNode<LineEdit>("Ui/MaxPlayerMenu/Selector").Value + 1;
        refreshPlayerCountLabel();
        this.GetNode<Control>("Ui/MaxPlayerMenu").Visible = false;
        this.GetNode<Button>("Ui/StartServer").Disabled = false;
    }
}