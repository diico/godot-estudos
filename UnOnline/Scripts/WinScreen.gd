extends Control

func _ready():
	$Panel/Name.text = GameState.romm_data["game"]["winner"]

func _on_BtnExit_pressed():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
