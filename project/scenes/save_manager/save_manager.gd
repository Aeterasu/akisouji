extends Node

var seen_tutorial : bool = false

func _save():
	var save_file = FileAccess.open("user://leafsweep.save", FileAccess.WRITE)

	var save_dict = {
		"cash" : CashManager.cash,
		"buy_0" : UpgradeManager._is_upgrade_bought(0),
		"buy_1" : UpgradeManager._is_upgrade_bought(1),
		"buy_2" : UpgradeManager._is_upgrade_bought(2),
		"buy_3" : UpgradeManager._is_upgrade_bought(3),
		"buy_4" : UpgradeManager._is_upgrade_bought(4),
		"buy_5" : UpgradeManager._is_upgrade_bought(5),
		"equipped" : UpgradeManager._get_equipped_boots_id(),
		"level_0_grade" : HighscoreManager.level_grades[0],
		"level_0_highscore" : HighscoreManager.level_highscores[0],
		"level_1_grade" : HighscoreManager.level_grades[1],
		"level_1_highscore" : HighscoreManager.level_highscores[1],
		"level_2_grade" : HighscoreManager.level_grades[2],
		"level_2_highscore" : HighscoreManager.level_highscores[2],
		"level_3_grade" : HighscoreManager.level_grades[3],
		"level_3_highscore" : HighscoreManager.level_highscores[3],
		"seen_tutorial" : seen_tutorial,
	}

	var json = JSON.stringify(save_dict)
	save_file.store_line(json)

	#return save_dict

func _load():
	if not FileAccess.file_exists("user://leafsweep.save"):
		return # Error! We don't have a save to load.	

	var save_file = FileAccess.open("user://leafsweep.save", FileAccess.READ)

	var json_string = save_file.get_line()

	# Creates the helper class to interact with JSON.
	var json = JSON.new()

	# Check if there is any error while parsing the JSON string, skip in case of failure.
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	
	var data = json.data

	CashManager.cash = data["cash"]

	if (data["buy_0"]):
		UpgradeManager._grant_upgrade_by_id(0)

	if (data["buy_1"]):
		UpgradeManager._grant_upgrade_by_id(1)

	if (data["buy_2"]):
		UpgradeManager._grant_upgrade_by_id(2)

	if (data["buy_3"]):
		UpgradeManager._grant_upgrade_by_id(3)

	if (data["buy_4"]):
		UpgradeManager._grant_upgrade_by_id(4)

	if (data["buy_5"]):
		UpgradeManager._grant_upgrade_by_id(5)

	UpgradeManager._set_equipped_boots_by_id(data["equipped"])

	HighscoreManager.level_grades[0] = int(data["level_0_grade"])
	HighscoreManager.level_highscores[0] = int(data["level_0_highscore"])

	HighscoreManager.level_grades[1] = int(data["level_1_grade"])
	HighscoreManager.level_highscores[1] = int(data["level_1_highscore"])

	HighscoreManager.level_grades[2] = int(data["level_2_grade"])
	HighscoreManager.level_highscores[2] = int(data["level_2_highscore"])

	HighscoreManager.level_grades[3] = int(data["level_3_grade"])
	HighscoreManager.level_highscores[3] = int(data["level_3_highscore"])

	if (data.has("seen_tutorial")):
		seen_tutorial = data["seen_tutorial"]
	else:
		seen_tutorial = false