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
    private Server Server;

    public override void _Ready(){
        ServerTabBtn = this.GetNode<Button>("ServerTabButton");
        PlayersTabBtn = this.GetNode<Button>("PlayersTabButton");
        KickBtn = this.GetNode<Button>("PlayersTab/KickButton");
        ValidateBtn = this.GetNode<Button>("PlayersTab/KickWindow/ValidateButton");
        CancelBtn = this.GetNode<Button>("PlayersTab/KickWindow/CancelButton");
        PlayersList = this.GetNode<ItemList>("PlayersTab/PlayersList");
        DataManager = this.GetNode<DataManager>("/root/DataManager");
        Server = this.GetNode<Server>("/root/Server");

        ServerTabBtn.Connect("toggled", this, "ServerTabBtnToggled");
        PlayersTabBtn.Connect("toggled", this, "PlayersTabBtnToggled");
        KickBtn.Connect("pressed", this, "KickBtnPressed");
        ValidateBtn.Connect("pressed", this, "ValidateBtnPressed");
        CancelBtn.Connect("pressed", this, "CancelBtnPressed");
        PlayersList.Connect("item_selected", this, "PlayersListItemSelected");
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
        if (!PlayersList.Items.Contains(playerName)){
            PlayersList.AddItem(playerName);
        }
    }

    public void removePlayerFromList(string playerName){
        for (int i = 0; i < PlayersList.GetItemCount(); i++){
            if (PlayersList.GetItemText(i) == playerName){
                PlayersList.RemoveItem(i);
            }
        }
    }

    private void PlayersListItemSelected(int index){
        KickBtn.Disabled = false;
        string playerName = PlayersList.GetItemText(index);
        int playerId = (int)DataManager.getIdFromName(playerName);
        selectedPlayerId = playerId;
        this.GetNode<Label>("PlayersTab/PlayerNameLabel").Text = "Player name: " + playerName;
        this.GetNode<Label>("PlayersTab/PlayerIdLabel").Text = "Connection ID: " + playerId.ToString();
    }

    private void KickBtnPressed(){
        this.GetNode<Control>("PlayersTab/KickWindow").Visible = true;
    }

    private void ValidateBtnPressed(){
        if (DataManager.connectedPlayersDictionary.Contains(selectedPlayerId)){
            Server.kickPlayer(selectedPlayerId, this.GetNode<LineEdit>("PlayersTab/KickWindow/Reason").Text);
            CancelBtnPressed();
        }
    }

    private void CancelBtnPressed(){
        this.GetNode<Control>("PlayersTab/KickWindow").Visible = false;
        this.GetNode<LineEdit>("PlayersTab/KickWindow/Reason").Text = "";
    }
}
