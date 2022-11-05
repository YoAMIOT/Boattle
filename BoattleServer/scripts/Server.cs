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
    private Log Log;
    private DataManager DataManager;
    private PasswordManager PasswordManager;

    public override void _Ready() {
        Log = this.GetNode <Log> ("Ui/Log");
        DataManager = this.GetNode <DataManager> ("/root/DataManager");
        PasswordManager = this.GetNode <PasswordManager> ("/root/PasswordManager");
        OS.WindowFullscreen = false;
        GetTree().SetAutoAcceptQuit(false);
        UPNP.Discover(2000, 2, "InternetGatewayDevice");
        ip = UPNP.QueryExternalAddress();
        UPNP.AddPortMapping(port, port, "BoattleServer", "UDP");
        UPNP.AddPortMapping(port, port, "BoattleServer", "TCP");
        this.GetNode <Label> ("Ui/IpLabel").Text = ip;
        this.GetNode <Button> ("Ui/MaxPlayerMenu/ValidateButton").Connect("pressed", this, "ValidateButtonPressed");
        this.GetNode <Button> ("Ui/StartServer").Connect("pressed", this, "StartServerPressed");
        this.GetNode <Button> ("Ui/Close").Connect("pressed", this, "closeButtonPressed");
        this.GetNode <Timer> ("TurnCooldown").Connect("timeout", this, "turnCooldownTimeOut");
    }

    private void ValidateButtonPressed() {
        maxPlayers = (int) this.GetNode <SpinBox> ("Ui/MaxPlayerMenu/Selector").Value + 1;
        refreshPlayerCountLabel();
        this.GetNode <Control> ("Ui/MaxPlayerMenu").Visible = false;
        this.GetNode <Button> ("Ui/StartServer").Disabled = false;
    }

    private void StartServerPressed() {
        serverStarted = true;
        this.GetNode <Button> ("Ui/StartServer").Disabled = true;
        Network.CreateServer(port, maxPlayers);
        GetTree().NetworkPeer = Network;
        Log.logPrint("!- SERVER STARTED -!");
        Network.Connect("peer_connected", this, "PeerConnected");
        Network.Connect("peer_disconnected", this, "PeerDisconnected");
        this.GetNode <Timer> ("TurnCooldown").Start();
    }

    private void PeerConnected(int playerId) {
        if (DataManager.connectedPlayersDictionary.Count == maxPlayers - 1) {
            kickPlayer(playerId, "This server is full");
        }
    }

    private void PeerDisconnected(int playerId) {
        Log.logPrint("!- " + (string)DataManager.connectedPlayersDictionary[playerId] + " disconnected -!");
        DataManager.playerDisconnected(playerId);
        refreshPlayerCountLabel();
        if (this.GetNode <Node> ("PasswordTimers").HasNode(playerId.ToString())) {
            this.GetNode <Node> ("PasswordTimers/" + playerId.ToString()).Disconnect("timeout", this, "kickPlayer");
            this.GetNode <Node> ("PasswordTimers/" + playerId.ToString()).QueueFree();
        }
        RpcId(0, "killPuppet", playerId);
    }

    [Remote]
    public void newConnectionEstablished(string playerName, int playerId) {
        bool registration = false;
        Log.logPrint("!- " + playerName + " connected -!");
        if (!DataManager.playersPasswordsDictionary.Contains(playerName)) {
            Vector2 position = Vector2.Zero;
            DataManager.saveDatasOfAPlayer(playerName, position);
            DataManager.createShipStatsForAPlayer(playerName);
            registration = true;
        }
        bool hasPlayerConnected = DataManager.isPlayerConnected(playerName);
        if (hasPlayerConnected) {
            kickPlayer(playerId, "Player already connected");
        } else if (!hasPlayerConnected) {
            DataManager.playerConnected(playerId, playerName);
            refreshPlayerCountLabel();
            RpcId(playerId, "authentication", registration);
            Timer TimeOutTimer = new Timer();
            this.GetNode <Node> ("PasswordTimers").AddChild(TimeOutTimer);
            TimeOutTimer.Name = playerId.ToString();
            TimeOutTimer.WaitTime = 60;
            TimeOutTimer.OneShot = true;
            Godot.Collections.Array arr = new Godot.Collections.Array();
            arr.Add(playerId);
            TimeOutTimer.Connect("timeout", this, "kickPlayer", arr);
            TimeOutTimer.Start();
        }
    }

    [Remote]
    public void receivePasswordValidationRequest(bool registration, string password, string playerName) {
        PasswordManager.validatePassword(registration, password, playerName);
    }

    public void logIn(int playerId, string playerName) {
        this.GetNode <Timer> ("PasswordTimers/" + playerId.ToString()).Disconnect("timeout", this, "kickPlayer");
        this.GetNode <Timer> ("PasswordTimers/" + playerId.ToString()).QueueFree();
        Vector2 playerPosition = new Vector2((float)(DataManager.playersDatasDictionary[playerName] as Godot.Collections.Dictionary)["posX"], (float)(DataManager.playersDatasDictionary[playerName] as Godot.Collections.Dictionary)["posY"]);
        //CHECK HERE the lines beneath
        Godot.Collections.Dictionary playerShipsDatas = (Godot.Collections.Dictionary)DataManager.shipsDictionary["default"];
        //Godot.Collections.Dictionary playerShipsDatas = (Godot.Collections.Dictionary)(DataManager.shipsDictionary[(DataManager.playersShipsStatsDictionary[playerName]as Godot.Collections.Dictionary)] as Godot.Collections.Dictionary)["ship"];
        //CHECK HERE the line beneath has a bad cast
        int currentHealth = (int)(DataManager.playersShipsStatsDictionary[playerName] as Godot.Collections.Dictionary)["health"];
        int maxHealth = (int)(DataManager.shipsDictionary[(DataManager.playersShipsStatsDictionary[playerName] as Godot.Collections.Dictionary)["ship"]] as Godot.Collections.Dictionary)["maxHealth"];
        Log.logPrint("!- " + playerName + " authentified -!");
        RpcId(0, "spawnPuppet", playerId, playerName, playerPosition, maxHealth, currentHealth);
        RpcId(playerId, "logIn", playerPosition, playerShipsDatas, currentHealth);
    }

    public void wrongPasswordEntered(int playerId) {
        RpcId(playerId, "wrongPassword");
    }

    public async void kickPlayer(int playerId, string reason = "You did not enter your password in time, please retry.") {
        Log.logPrint("!- " + DataManager.connectedPlayersDictionary[playerId] + " was kicked: " + reason + " -!");
        RpcId(playerId, "kickedFromServer", reason);
        Timer Timer = new Timer();
        Timer.Autostart = true;
        Timer.WaitTime = 0.1F;
        Timer.OneShot = true;
        this.AddChild(Timer);
        await ToSignal(Timer, "timeout");
        Timer.QueueFree();
        Network.DisconnectPeer(playerId, true);
    }

    private void refreshPlayerCountLabel() {
        this.GetNode <Label> ("Ui/ConnectedPeersLabel").Text = "Connected: " + DataManager.connectedPlayersDictionary.Count.ToString() + "/" + (maxPlayers - 1).ToString();
    }

    public override void _Notification(int what) {
        if (what == MainLoop.NotificationWmQuitRequest) {
            GetTree().Quit();
        }
    }

    private void closeButtonPressed() {
        _Notification(MainLoop.NotificationWmQuitRequest);
    }

    [Remote]
    private void receiveTurnData(string action, Vector2 position, string playerName = "", double radius = 0.1) {
        DataManager.turnDictionary[playerName] = new Godot.Collections.Dictionary{
            {"action", action},
            {"position", position},
            {"radius",radius}
        };
    }

    private void turnCooldownTimeOut() {
        turn = !turn;
        RpcId(0, "turnSwitch", turn);
        if (turn == false){
            int generalRange = 384;
            Godot.Collections.Dictionary worldState = new Godot.Collections.Dictionary();
            Godot.Collections.Dictionary registeredShots = new Godot.Collections.Dictionary();
            foreach (var p in DataManager.turnDictionary){
                string playerName = DataManager.connectedPlayersDictionary[p].ToString();
                Vector2 currentPosition = new Vector2((float)(DataManager.playersDatasDictionary[playerName] as Godot.Collections.Dictionary)["posX"], (float)(DataManager.playersDatasDictionary[playerName] as Godot.Collections.Dictionary)["posX"]);
                worldState[p] = new Godot.Collections.Dictionary{
                    {"playerName", playerName},
                    {"position", currentPosition}
                };
                if (DataManager.turnDictionary.Contains(playerName)){
                    if ((string)(DataManager.turnDictionary[playerName]as Godot.Collections.Dictionary)["action"] == "move"){
                        if(currentPosition.DistanceTo((Vector2)(DataManager.turnDictionary[playerName] as Godot.Collections.Dictionary)["position"]) < (generalRange * (float)(DataManager.shipsDictionary[(DataManager.playersShipsStatsDictionary[playerName] as Godot.Collections.Dictionary)["ship"]] as Godot.Collections.Dictionary)["moveRange"])){
                            DataManager.saveDatasOfAPlayer(playerName, (Vector2)(DataManager.turnDictionary[playerName] as Godot.Collections.Dictionary)["position"]);
                            (worldState[p] as Godot.Collections.Dictionary)["position"] = (Vector2)(DataManager.turnDictionary[playerName] as Godot.Collections.Dictionary)["position"];
                        }
                    } else if ((string)(DataManager.turnDictionary[playerName] as Godot.Collections.Dictionary)["action"] == "shoot"){
                        float shotRadius = (float)(DataManager.turnDictionary[playerName] as Godot.Collections.Dictionary)["radius"];
                        if (currentPosition.DistanceTo((Vector2)(DataManager.turnDictionary[playerName] as Godot.Collections.Dictionary)["position"]) < (generalRange * (float)(DataManager.shipsDictionary[(DataManager.playersShipsStatsDictionary[playerName] as Godot.Collections.Dictionary)["ship"]] as Godot.Collections.Dictionary)["shootRange"])){
                            if (shotRadius <= (float)(DataManager.shipsDictionary[(DataManager.playersShipsStatsDictionary[playerName] as Godot.Collections.Dictionary)["ship"]] as Godot.Collections.Dictionary)["maxRadius"] && shotRadius >= (float)(DataManager.shipsDictionary[(DataManager.playersShipsStatsDictionary[playerName] as Godot.Collections.Dictionary)["ship"]] as Godot.Collections.Dictionary)["minRadius"]){
                                registeredShots[playerName] = new Godot.Collections.Dictionary{
                                    {"position",(Vector2)(DataManager.turnDictionary[playerName] as Godot.Collections.Dictionary)["position"]},
                                    {"radius", shotRadius}
                                };
                            }
                        }
                    }
                }
            }
            foreach(var s in registeredShots){
                Godot.Collections.Dictionary targets = new Godot.Collections.Dictionary();
                foreach(int p in DataManager.connectedPlayersDictionary){
                    string playerName = (string)DataManager.connectedPlayersDictionary[p];
                    Vector2 registeredShotPos = (Vector2)(registeredShots[s] as Godot.Collections.Dictionary)["position"];
                    if (registeredShotPos.DistanceTo(new Vector2((float)(DataManager.playersDatasDictionary[playerName] as Godot.Collections.Dictionary)["posX"] , (float)(DataManager.playersDatasDictionary[playerName] as Godot.Collections.Dictionary)["posY"])) < (generalRange * (float)(registeredShots[s] as Godot.Collections.Dictionary)["radius"])){
                        int appliedDamage = (int)(DataManager.shipsDictionary[(DataManager.playersShipsStatsDictionary[s] as Godot.Collections.Dictionary)["ship"]] as Godot.Collections.Dictionary)["damage"] - (int)((float)(registeredShots[s] as Godot.Collections.Dictionary)["radius"] * (float)(DataManager.shipsDictionary[(DataManager.playersShipsStatsDictionary[s] as Godot.Collections.Dictionary)["ship"]] as Godot.Collections.Dictionary)["damage"]);
                        if ((int)(DataManager.playersShipsStatsDictionary[playerName]as Godot.Collections.Dictionary)["health"] > 0){
                            DataManager.setHealthForAPlayer(playerName, true, appliedDamage);
                        }
                        targets[p] = (int)(DataManager.playersShipsStatsDictionary[playerName] as Godot.Collections.Dictionary)["health"];
                    }
                }
                RpcId(0, "shootOnPos", s, (Vector2)(registeredShots[s]as Godot.Collections.Dictionary)["position"], (float)(registeredShots[s]as Godot.Collections.Dictionary)["radius"], targets);
            }
            RpcId(0, "receiveWorldState", worldState);
            DataManager.savePlayersShipsStats();
            DataManager.turnDictionary = new Godot.Collections.Dictionary();
        }
    }
}