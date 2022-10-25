using Godot;
using System;

public class UI : Control{
    private Button ServerTabBtn;
    private Button PlayersTabBtn;
    private Button KickBtn;
    private Button ValidateBtn;
    private Button CancelBtn;
    private ItemList PlayersList;
    private int selectedPlayerId;
    private DataManager DataManager;

    public override void _Ready(){
        ServerTabBtn = this.GetNode<Button>("ServerTabButton");
        PlayersTabBtn = this.GetNode<Button>("PlayersTabButton");
        KickBtn = this.GetNode<Button>("PlayersTab/KickButton");
        ValidateBtn = this.GetNode<Button>("PlayersTab/KickWindow/ValidateButton");
        CancelBtn = this.GetNode<Button>("PlayersTab/KickWindow/CancelButton");
        PlayersList = this.GetNode<ItemList>("PlayersTab/PlayersList");
        DataManager = this.GetNode<DataManager>("root/DataManager");

        ServerTabBtn.Connect("toggled", this, "ServerTabBtnToggled", pressed);
        PlayersTabBtn.Connect("toggled", this, "PlayersTabBtnToggled", pressed);
        KickBtn.Connect("pressed", this, "KickBtnPressed");
        ValidateBtn.Connect("pressed", this, "ValidateBtnPressed");
        CancelBtn.Connect("pressed", this, "CancelBtnPressed");
        PlayersList.Connect("item_selected", this, "PlayersListItemSelected", index);
    }

    private void ServerTabBtnToggled(bool pressed){
        if (pressed){
            ServerTabBtn.Disabled = true;
            PlayersTabBtn.Disabled = false;
            PlayersTabBtn.Pressed = false;
            this.GetNode<Control>("PlayersTab").Visible = false;
        }
    }
  
    private void PlayersTabBtnToggled(bool pressed){
        if (pressed){
            PlayersTabBtn.Disabled = true;
            ServerTabBtn.Disabled = false;
            ServerTabBtn.Pressed = false;
            this.GetNode<Control>("PlayersTab").Visible = true;
        }
    }

    public void addPlayerToList(string playerName){
        if (!PlayerList.Items.Has(playerName)){
            PlayeList.AddItem(playerName);
        }
    }

    public void removePlayerFromList(string playerName){
        for (int i = 0; i < PlayerList.GetItemCount(); i++){
            if (PlayerList.GetItemText(i) == playerName){
                PlayerList.RemoveItem(i);
            }
        }
    }

    private void PlayersListItemSelected(int index){
        KickBtn.Disabled = false;
        private string playerName = PlayerList.GetItemText(index);
        private int playerId = DataManager.getIdFromName(playerName);
        selectedPlayerId = playerId;
        private int generalRange = 384;
        this.GetNode<Label>("PlayersTab/PlayerNameLabel").Text = "Player name: " + playerName; 
        this.GetNode<Label>("PlayersTab/PlayerIdLabel").Text = "Connection ID: " + <string>playerId; 
        this.GetNode<Label>("PlayersTab/PlayerViewRangeLabel").Text = "View range: " + <string>(generalRange * DataManager.shipsDictionary[DataManager.playerShipsStatsDictionary[playerName].ship].viewRange); 
        this.GetNode<Label>("PlayersTab/PlayerMoveRangeLabel").Text = "Move range: " + <string>(generalRange * DataManager.shipsDictionary[DataManager.playerShipsStatsDictionary[playerName].ship].moveRange); 
        this.GetNode<Label>("PlayersTab/PlayerShootRangeLabel").Text = "Shoot range: " + <string>(generalRange * DataManager.shipsDictionary[DataManager.playerShipsStatsDictionary[playerName].ship].shootRange);
    }

    private void KickBtnPressed(){
        this.GetNode<Control>("PlayersTab/KickWindow").Visible = true;
    }

    private void ValidateBtnPressed(){
        if (DataManager.connectedPlayersDictionary.Has(selectedPlayerId)){
            this.GetParent().kickPlayer(selectedPlayerId, this.GetNode<Label>("PlayersTab/KickWindow/reason").text);
        }
        CancelBtnPressed();
    }
    
    private void CancelBtnPressed(){
        this.GetNode<Control>("PlayersTab/KickWindow").Visible = false;
        this.GetNode<Label>("PlayersTab/KickWindow/reason").text = "";
    }
}
