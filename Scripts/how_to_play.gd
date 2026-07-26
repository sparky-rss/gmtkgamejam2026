extends Node2D

func _ready() -> void:
	$CanvasLayer/HowToPlay.grab_focus()
func _on_how_to_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
