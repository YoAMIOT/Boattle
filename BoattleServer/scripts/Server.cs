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
    private DataManager DataManager;

    public override void _Ready() {
        Log = this.GetNode < RichTextLabel > ("Ui/Log");
        Os.SetWindowFullscreen(false);
        GetTree().SetAutoAcceptQuit(false);
        UPNP.Discover(2000, 2, "InternetGatewayDevice");
        ip = UPNP.QueryExternalAddress();
        UPNP.AddPortMapping(port, port, "BoattleServer", "UDP");
        UPNP.AddPortMapping(port, port, "BoattleServer", "TCP");
        this.GetNode < Label > ("UI/IpLabel").Text = ip;

        #this.GetNode < Button > ("Ui/").Connect("pressed", this, "ValidateButtonPressed");
        this.GetNode < Button > ("Ui/StartServer").Connect("pressed", this, "StartServerPressed");
    }

    private void ValidateButtonPressed() {
        maxPlayers = this.GetNode < LineEdit > ("Ui/MaxPlayerMenu/Selector").Value + 1;
        refreshPlayerCountLabel();
        this.GetNode < Control > ("Ui/MaxPlayerMenu").Visible = false;
        this.GetNode < Button > ("Ui/StartServer").Disabled = false;
    }

    private void StartServerPressed() {
        serverStarted = true;
        this.GetNode < Button > ("Ui/StartServer").Disabled = true;
        Network.CreateServer(port, maxPlayers);
        GetTree().SetNetworkPeer(Network);
        Network.Connect("peer_connected", this, "PeerConnected");
        Network.Connect("peer_disconnected", this, "PeerDisconnected");
        this.GetNode<Timer>("TurnCooldown").Start();
    }
    
    private void PeerConnected(int PlayerId) {
        if (DataManager.connectedPlayersDictionnary.Size() == maxPlayers - 1){
            kickPlayer(PlayerId, "This server is full");
        }
    }
    
    private void PeerDisconnected(int PlayerId) {
        Log.LogPrint("!- " + (string)DataManager.connectedPlayersDictionnary[PlayerId] + " disconnected -!");
        DataManager.playerDisconnected(PlayerId);
        refreshPlayerCountLabel();
        if this.GetNode<Node>("PasswordTimers").HasNode(PlayerId.ToString()){
            this.GetNode<Node>("PasswordTimers" + PlayerId.ToString()).Disconnect("timeout", this, "kickPlayer");
            this.GetNode<Node>("PasswordTimers" + PlayerId.ToString()).QueuFree();
        }
        RpcId(0, "killPuppet", PlayerId);
    }
}