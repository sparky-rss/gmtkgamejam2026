extends Node2D


func _ready() -> void:
	$CanvasLayer/Label/GridContainer/Start.grab_focus() 
	if not MenuMusic.get_node("Menu").playing:
		MenuMusic.get_node("Menu").play()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_how_to_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/how_to_play.tscn")
