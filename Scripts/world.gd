extends Node2D

var blackout_tween : Tween

func _ready() -> void:
	if Globals.new_game:
		Globals.setup()

func setup_new_day():
	Globals.remaining_moves = Globals.total_moves
	var den_pos : Vector2 = $TileMapLayer.map_to_local(Globals.den_position)
	den_pos -= (Globals.tile_size/2)
	$CharacterBody2D.global_position = den_pos

func pass_time():
	Globals.remaining_moves -= 1
	$HUD_Layer/HUD/Moves.update_moves()
	if Globals.remaining_moves == 0:
		Globals.end_of_day = true
		var den_pos : Vector2 = $TileMapLayer.map_to_local(Globals.den_position)
		den_pos -= (Globals.tile_size/2)
		blackout_tween = create_tween()
		blackout_tween.tween_property($HUD_Layer/Blackout, "color:a", 0.3, 1)
		await get_tree().create_timer(1).timeout
		if !Globals.map_position == Globals.den_position:
			$CharacterBody2D._move_to_den(den_pos)
		await get_tree().create_timer(1.5).timeout
		$CharacterBody2D/PlayerSprite.fall_asleep()
		blackout_tween = create_tween()
		blackout_tween.tween_property($HUD_Layer/Blackout, "color:a", 1.0, 2.0)
		
