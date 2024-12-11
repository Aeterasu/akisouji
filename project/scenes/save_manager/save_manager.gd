extends Node

var seen_tutorial : bool = false

var beat_0 : bool = false
var beat_1 : bool = false
var beat_2 : bool = false
var beat_3 : bool = false

var seen_finale : bool = false

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
		"beat_0" : beat_0,
		"beat_1" : beat_1,
		"beat_2" : beat_2,
		"beat_3" : beat_3,
		"level_0_grade" : HighscoreManager.level_grades[0],
		"level_0_highscore" : HighscoreManager.level_highscores[0],
		"level_1_grade" : HighscoreManager.level_grades[1],
		"level_1_highscore" : HighscoreManager.level_highscores[1],
		"level_2_grade" : HighscoreManager.level_grades[2],
		"level_2_highscore" : HighscoreManager.level_highscores[2],
		"level_3_grade" : HighscoreManager.level_grades[3],
		"level_3_highscore" : HighscoreManager.level_highscores[3],
		"level_4_grade" : HighscoreManager.level_grades[4],
		"level_4_highscore" : HighscoreManager.level_highscores[4],
		"seen_tutorial" : seen_tutorial,
		"seen_finale" : seen_finale,
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

	beat_0 = data["beat_0"]
	beat_1 = data["beat_1"]
	beat_2 = data["beat_2"]
	beat_3 = data["beat_3"]

	UpgradeManager._set_equipped_boots_by_id(data["equipped"])

	HighscoreManager.level_grades[0] = int(data["level_0_grade"])
	HighscoreManager.level_highscores[0] = int(data["level_0_highscore"])

	HighscoreManager.level_grades[1] = int(data["level_1_grade"])
	HighscoreManager.level_highscores[1] = int(data["level_1_highscore"])

	HighscoreManager.level_grades[2] = int(data["level_2_grade"])
	HighscoreManager.level_highscores[2] = int(data["level_2_highscore"])

	HighscoreManager.level_grades[3] = int(data["level_3_grade"])
	HighscoreManager.level_highscores[3] = int(data["level_3_highscore"])

	HighscoreManager.level_grades[4] = int(data["level_4_grade"])
	HighscoreManager.level_highscores[4] = int(data["level_4_highscore"])

	if (data.has("seen_tutorial")):
		seen_tutorial = data["seen_tutorial"]
	else:
		seen_tutorial = false

	if (data.has("seen_finale")):
		seen_finale = data["seen_finale"]
	else:
		seen_finale = false