using Godot;
using System;

public class PauseMenu : Node{

    private Button ResumeBtn;
    private Button OptionsBtn;
    private Button LeaveBtn;

    public override void _Ready(){
        ResumeBtn = this.GetNode("MainPauseMenu/ResumeButton");
        OptionsBtn = this.GetNode("MainPauseMenu/OptionsButton");
        LeaveBtn = this.GetNode("MainPauseMenu/LeaveButton");
        ResumeBtn.Connect("pressed", this, "resumeBtnPressed");
        OptionsBtn.Connect("pressed", this, "optionsBtnPressed");
        LeaveBtn.Connect("pressed", this, "leaveBtnPressed");
    }

    private void resumeBtnPressed(){
        this.Visible = false;
        this.GetParent().GetNode("GameUI").Visible = true;
    }

    private void optionsBtnPressed(){

    }

    public void backOptions(){
        this.GetNode("OptionsMenu").Visible = false;
        this.GetNode("MainPauseMenu").Visible = true;
    }

    private void leaveBtnPressed(){

    }
}
