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

    public override void _Ready(){
        ServerTabBtn = this.GetNode<Button>("ServerTabButton");
        PlayersTabBtn = this.GetNode<Button>("PlayersTabButton");
        KickBtn = this.GetNode<Button>("PlayersTab/KickButton");
        ValidateBtn = this.GetNode<Button>("PlayersTab/KickWindow/ValidateButton");
        CancelBtn = this.GetNode<Button>("PlayersTab/KickWindow/CancelButton");
        PlayersList = this.GetNode<ItemList>("PlayersTab/PlayersList");

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
        
    }
}
