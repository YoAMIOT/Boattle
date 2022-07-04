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
			validatePassword(registration, password);

func _on_ValidatePassword_pressed() -> void:
	var registration : bool = false;
	if get_node("AlreadyRegistered/Password").text.length() < 8:
		get_node("Error/Label").text = "To be safe, your password must be above 8 characters";
		get_node("Error").popup();
	elif get_node("AlreadyRegistered/Password").text.length() >= 8:
		var password : String = get_node("AlreadyRegistered/Password").text;
		validatePassword(registration, password);



func validatePassword(registration : bool, password : String) -> void:
	if registration == true:
		var salt : String = generateSalt();
		var hashedPassword : String = generateHashedPassword(password, salt);
	elif registration == false:
		print("C'est bon login");

func generateSalt() -> String:
	randomize();
	var salt = str(randi()).sha256_text();
	return salt;

func generateHashedPassword(password, salt) -> String:
	var hashedPassword : String = password;
	var rounds : int = pow(2, 3);
	while rounds > 0:
		hashedPassword = (hashedPassword + salt).sha256_text();
		rounds -= 1;
	return hashedPassword;

func _on_Error_popup_hide() -> void:
	get_node("Error/Label").text = "";
