using Godot;
using System;

public class PauseMenu : Control{

    private Button ResumeBtn;
    private Button OptionsBtn;
    private Button LeaveBtn;
    private Server Server;

    public override void _Ready(){
        ResumeBtn = this.GetNode<Button>("MainPauseMenu/ResumeButton");
        OptionsBtn = this.GetNode<Button>("MainPauseMenu/OptionsButton");
        LeaveBtn = this.GetNode<Button>("MainPauseMenu/LeaveButton");
        Server = this.GetNode<Server>("/root/Server");
        ResumeBtn.Connect("pressed", this, "resumeBtnPressed");
        OptionsBtn.Connect("pressed", this, "optionsBtnPressed");
        LeaveBtn.Connect("pressed", this, "leaveBtnPressed");
    }

    private void resumeBtnPressed(){
        this.Visible = false;
        this.GetParent().GetNode<Control>("GameUI").Visible = true;
    }

    private void optionsBtnPressed(){
        this.GetNode<Control>("MainPauseMenu").Visible = false;
        this.GetNode<Control>("OptionsMenu").refresh();
        this.GetNode<Control>("OptionsMenu").Visible = true;
    }

    public void backOptions(){
        this.GetNode<Control>("OptionsMenu").Visible = false;
        this.GetNode<Control>("MainPauseMenu").Visible = true;
    }

    private void leaveBtnPressed(){
        Server.disconnectFromServer();
    }
}
