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
        this.GetNode<Label>("UI/IpLabel").Text = ip;
        this.GetNode<Button>("Ui/MaxPlayerMenu/ValidateButton").Connect("pressed", this, "ValidateButtonPressed");
        this.GetNode<Button>("Ui/StartServer").Connect("pressed", this, "StartServerPressed");
    }

    private void ValidateButtonPressed() {
        maxPlayers = this.GetNode<LineEdit>("Ui/MaxPlayerMenu/Selector").Value + 1;
        refreshPlayerCountLabel();
        this.GetNode<Control>("Ui/MaxPlayerMenu").Visible = false;
        this.GetNode<Button>("Ui/StartServer").Disabled = false;
    }

    private void StartServerPressed() {
        serverStarted = true;
        this.GetNode<Button>("Ui/StartServer").Disabled = true;
        Network.CreateServer(port, maxPlayers);
        GetTree().SetNetworkPeer(Network);
        Network.Connect("peer_connected", this, "PeerConnected");
        Network.Connect("peer_disconnected", this, "PeerDisconnected");
        this.GetNode<Timer>("TurnCooldown").Start();
    }
    
    private void PeerConnected(int playerId) {
        if (DataManager.connectedPlayersDictionnary.Size() == maxPlayers - 1){
            kickPlayer(playerId, "This server is full");
        }
    }
    
    private void PeerDisconnected(int playerId) {
        Log.logPrint("!- " + (string)DataManager.connectedPlayersDictionnary[playerId] + " disconnected -!");
        DataManager.playerDisconnected(playerId);
        refreshPlayerCountLabel();
        if (this.GetNode<Node>("PasswordTimers").HasNode(playerId).ToString()){
            this.GetNode<Node>("PasswordTimers" + playerId.ToString()).Disconnect("timeout", this, "kickPlayer");
            this.GetNode<Node>("PasswordTimers" + playerId.ToString()).QueuFree();
        }
        RpcId(0, "killPuppet", playerId);
    }
    
    [Remote]
    public void newConnectionEstablished(string playerName, int playerId){
        bool registration = false;
        Log.logPrint("!- " + playerName + " connected -!");
        if (!DataManager.playersPasswordDictionary.Contains(playerName)){
            Vector2 position = Vector2(0,0);
            DataManager.saveDatasOfAPlayer(playerName, position);
            DataManager.createShipStatsForAPlayer(playerName);
            registration = true;
        }
        bool hasPlayerConnected = DataManager.isPlayerConnected(playerName);
        if (hasPlayerConnected){
            kickPlayer(playerId, "Player already connected");
        }
    }
}