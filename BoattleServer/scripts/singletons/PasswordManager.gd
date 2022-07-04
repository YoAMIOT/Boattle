extends Node

func validatePassword(registration : bool, password : String, playerName : String) -> void:
	var playerId : int;
	for p in DataManager.connectedPlayersDictionnary:
		if DataManager.connectedPlayersDictionnary[p] == playerName:
			playerId = p;
	if registration == true:
		var salt : String = generateSalt();
		var hashedPassword : String = generateHashedPassword(password, salt);
		DataManager.savePasswordsForPlayer(hashedPassword, salt, playerName);
		var register = false;
		validatePassword(register, password, playerName);
	elif registration == false:
		var retrievedSalt = DataManager.playersPasswords[playerName].salt;
		var hashedPassword = generateHashedPassword(password, retrievedSalt);
		if not hashedPassword == DataManager.playersPasswords[playerName].password:
			get_node("/root/Server").wrongPasswordEntered(playerId);
		elif hashedPassword == DataManager.playersPasswords[playerName].password:
			get_node("/root/Server").logIn(playerId, playerName);



func generateSalt() -> String:
	randomize();
	var salt = str(randi()).sha256_text();
	return salt;

func generateHashedPassword(password, salt) -> String:
	var hashedPassword : String = password;
	var rounds : int = pow(2, 18);
	while rounds > 0:
		hashedPassword = (hashedPassword + salt).sha256_text();
		rounds -= 1;
	return hashedPassword;
