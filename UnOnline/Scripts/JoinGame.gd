extends Control

enum {CONNECT, WAIT}

var state = CONNECT
var room_data

func _ready():
	GameState.host = false
	
	GameState.connect("snapshot_data", self, "_on_snapshot_data")

func _on_snapshot_data(data):
	room_data = data
	if state == CONNECT:
		if room_data == null or room_data["state"] != "open":
			$Panel/BtnOk.disabled = false
			$Panel/EditHost.editable = true
			$Panel/EditHost.text = ""
			$Panel/EditHost.placeholder_text = "inválido"
			GameState.remove_listener("rooms", GameState.room_name)
			return
		if room_data["state"] == "open":
			for i in range(4):
				if not room_data["players"].has(str(i)):
					room_data["players"][str(i)] = GameState.user_data["name"]
					GameState.me_n = i
					state = WAIT
					GameState.set_document("rooms", GameState.room_name, room_data)
					break
	elif state == WAIT:
		var nplayers = room_data["players"].size()
		for i in range(4):
			if room_data["players"].has(str(i)):
				get_node("Panel/LabPlayer" + str(i)).text = room_data["players"][str(i)]
			else:
				get_node("Panel/LabPlayer" + str(i)).text = "-"

		$Panel/LabNumPlayers.text = "Players (" + str(nplayers) + "/4)"

		if room_data["state"] == "start":
			GameState.romm_data = room_data
			get_tree().change_scene("res://Scenes/Game.tscn")
		elif room_data["state"] == "cancel":
			GameState.remove_listener("rooms", GameState.room_name)
			var info = load("res://Scenes/InfoScreen.tscn").instance()
			info.init("Atenção", "Host encerrou a sessão", 3, "res://Scenes/MainMenu.tscn")
			add_child(info)


func _on_BtnOk_pressed():
	if $Panel/EditHost.text.empty():
		return
	
	GameState.room_name = $Panel/EditHost.text
	GameState.set_listener("rooms", GameState.room_name)
	$Panel/BtnOk.disabled = true
	$Panel/EditHost.editable = false


func _on_BtnCancel_pressed():
	if state == WAIT:
		room_data["players"].erase(str(GameState.me_n))
		GameState.remove_listener("rooms", GameState.room_name)
		GameState.set_document("rooms", GameState.room_name, room_data)

	get_tree().change_scene("res://Scenes/MainMenu.tscn")
