extends Control

func _on_ValidateNewPassword_pressed() -> void:
	var registration : bool = true;
	if get_node("Registration/NewPassword").text != get_node("Registration/ConfirmPassword").text:
		get_node("Error/Label").text = "Passwords must be the same";
		get_node("Error").popup();
	elif get_node("Registration/NewPassword").text == get_node("Registration/ConfirmPassword").text:
		if get_node("Registration/NewPassword").text.length() < 8 or get_node("Registration/ConfirmPassword").text.length() < 8:
			get_node("Error/Label").text = "To be safe, your password must be above 8 characters";
			get_node("Error").popup();
		elif get_node("Registration/NewPassword").text.length() >= 8 and get_node("Registration/ConfirmPassword").text.length() >= 8:
			var password : String = get_node("Registration/NewPassword").text;
			Server.sendPasswordValidationRequest(registration, password);

func _on_ValidatePassword_pressed() -> void:
	var registration : bool = false;
	if get_node("AlreadyRegistered/Password").text.length() < 8:
		get_node("Error/Label").text = "To be safe, your password must be above 8 characters";
		get_node("Error").popup();
	elif get_node("AlreadyRegistered/Password").text.length() >= 8:
		var password : String = get_node("AlreadyRegistered/Password").text;
		Server.sendPasswordValidationRequest(registration, password);

func _on_Error_popup_hide() -> void:
	get_node("Error/Label").text = "";



func wrongPassword() -> void:
	get_node("Error/Label").text = "Wrong Password";
	get_node("Error").popup();



func reset() -> void:
	get_node("AlreadyRegistered/Password").text = "";
	get_node("Registration/NewPassword").text = "";
	get_node("Registration/ConfirmPassword").text = "";
	get_node("AlreadyRegistered").visible = false;
	get_node("Registration").visible = false;
