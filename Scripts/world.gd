extends Node2D

var blackout_tween : Tween
var pause : bool
const acorn_scene = preload("res://Scenes/acorn.tscn")

func _ready() -> void:
	MenuMusic.get_node("Menu").stop()
	$MainTheme.play()
	if Globals.new_game:
		Globals.setup()
		setup_first_day()
	Globals.mouth_inventory_changed.connect(mouth_inventory_update)
	get_node("HUD_Layer/HUD/Days").update_days()
	await get_tree().create_timer(2).timeout
	get_node("DayTimer").start(Globals.total_time)

func show_return():
	get_node("Return").show()
	get_node("Return").play("play", 2.0)
	
func hide_return():
	get_node("Return").hide()

func mouth_inventory_update(new_mouth_inventory : Array):
	if Globals.mouth_size == new_mouth_inventory.size():
		show_return()
	else:
		hide_return()
	if new_mouth_inventory == []:
		for i in Globals.mouth_size:
			var target_container = str("HUD_Layer/HUD/InventoryContainer/",i,"/AnimatedSprite2D")
			var target_node = get_node(target_container)
			target_node.hide()
	else:
		for i in new_mouth_inventory.size():
			var target_container = str("HUD_Layer/HUD/InventoryContainer/",i,"/AnimatedSprite2D")
			var target_node = get_node(target_container)
			target_node.show()
			target_node.play(new_mouth_inventory[i], 1.0)
			

func setup_first_day():
	setup_playable_area_array()
	create_terrain()
	generate_cave()
	generate_trees()
	#generate_rivers()
	spread_acorns()
	set_player_view()

func setup_playable_area_array():
	for x in 39:
		for y in 23:
			var relevant_vector : Vector2i = Vector2i(x-19, y-11)
			Globals.playable_area.append(relevant_vector)
			if x%4 == 0 and y %4 == 0:
				Globals.tree_spots.append(relevant_vector)

func create_terrain():
	for tile in Globals.playable_area:
		$TileMapLayer.set_cell(tile, 1, Vector2i(10, 2))
		
func generate_cave():
	$TreeLayer.set_cell(Globals.den_position + Vector2i(-1, -1), 10, Vector2i(0,0))
	
func generate_trees():
	Globals.tree_spots.shuffle()
	for tree in Globals.big_trees_to_generate:
		$TreeLayer.set_cell(Globals.tree_spots[tree], 0, (Vector2i(0, 0)))
		$TreeLayer.set_cell(Globals.tree_spots[tree] + Vector2i(1,0), 0, (Vector2i(1, 0)))
		$TreeLayer.set_cell(Globals.tree_spots[tree] + Vector2i(0,1), 0, (Vector2i(0, 1)))
		$TreeLayer.set_cell(Globals.tree_spots[tree] + Vector2i(1,1), 0, (Vector2i(1, 1)))
	var shuffled_atlas = Globals.playable_area.duplicate()
	shuffled_atlas.shuffle()
	for shrub in Globals.little_shrubs_to_generate:
		if $TreeLayer.get_cell_tile_data(shuffled_atlas[shrub]) == null:
			var shrub_to_use = randi_range(2, 9)
			if (abs(shuffled_atlas[shrub].x) <=2 and abs(shuffled_atlas[shrub].y) <=2):
				pass
			else:
				$TreeLayer.set_cell(shuffled_atlas[shrub], shrub_to_use, (Vector2i(0, 0)))

func spread_acorns():
	var open_spots : Array = Globals.playable_area.duplicate()
	var spots_to_erase : Array
	for spot in open_spots:
		if $TreeLayer.get_cell_tile_data(spot) != null:
			spots_to_erase.append(spot)
	for spot in spots_to_erase:
		open_spots.erase(spot)
	open_spots.shuffle()
	var total_acorn_count = Globals.acorn_count + Globals.silver_acorn_count + Globals.golden_acorn_count
	for i in total_acorn_count:
		var new_acorn = acorn_scene.instantiate()
		var acorn_pos : Vector2 = $TreeLayer.map_to_local(open_spots[i])
		var global_acorn_pos = to_global(acorn_pos)
		new_acorn.global_position = global_acorn_pos + Vector2(17,23)
		add_child(new_acorn)
		if i >=  Globals.acorn_count + Globals.silver_acorn_count:
			new_acorn.get_node(("AnimatedSprite2D")).play("golden", 1.0)
			new_acorn.state = "golden"
		elif i >= Globals.acorn_count and i < Globals.acorn_count + Globals.silver_acorn_count:
			new_acorn.get_node(("AnimatedSprite2D")).play("silver", 1.0)
			new_acorn.state = "silver"
		else:
			if abs(open_spots[i].x) > 18 or abs(open_spots[i].y) > 10:
				new_acorn.get_node(("AnimatedSprite2D")).play("golden", 1.0)
				new_acorn.state = "golden"
			elif abs(open_spots[i].x) > 16 or abs(open_spots[i].y) > 9:
				new_acorn.get_node(("AnimatedSprite2D")).play("silver", 1.0)
				new_acorn.state = "silver"
			else:
				new_acorn.get_node(("AnimatedSprite2D")).play("normal", 1.0)
				new_acorn.state = "normal"

func set_player_view():
	var player_cell = Globals.map_position
	for x in range(-Globals.visible_radius, Globals.visible_radius + 1):
		for y in range(-Globals.visible_radius, Globals.visible_radius + 1):
			var offset = Vector2i(x, y)
			var target_cell = player_cell + offset
			
			if offset.length() <= Globals.visible_radius:
				$FogLayer.set_cell(target_cell, 15, Vector2i(0,0))

func setup_new_day():
	Globals.remaining_moves = Globals.total_moves
	Globals.remaining_days -= 1
	if Globals.remaining_days == 0:
		game_over()
	else:
		$HUD_Layer/HUD/Days.update_days()
		$HUD_Layer/HUD/Moves.update_moves()
		get_node("HUD_Layer/HUD/Shop").hide()
		$CharacterBody2D/PlayerSprite.idle()
		blackout_tween = create_tween()
		blackout_tween.tween_property($HUD_Layer/Blackout, "color:a", 0.0, 2.0)
		get_node("HUD_Layer/HUD/Time").update_text(Globals.total_time)
		await get_tree().create_timer(2.2).timeout
		Globals.end_of_day = false
		await get_tree().create_timer(1).timeout
		get_node("DayTimer").start(Globals.total_time)

func pass_time():
	set_player_view()
	Globals.remaining_moves -= 1
	$HUD_Layer/HUD/Moves.update_moves()		

func disable_relevant_buttons():
	var disable_mouth_upgrade = Globals.MouthCapacityLevel == Globals.MouthCapacityMaxLevel
	if !disable_mouth_upgrade:
		disable_mouth_upgrade = Globals.banked_acorns < Globals.MouthCapacityCostArray[Globals.MouthCapacityLevel] 
	get_node("HUD_Layer/HUD/Shop/GridContainer/MouthCapacity").disabled = disable_mouth_upgrade
	var disable_vision_upgrade = Globals.VisionRadiusLevel == Globals.VisionRadiusMaxLevel
	if !disable_vision_upgrade:
		disable_vision_upgrade = Globals.banked_acorns < Globals.VisionRadiusCostArray[Globals.VisionRadiusLevel] 
	get_node("HUD_Layer/HUD/Shop/GridContainer/VisionRadius").disabled = disable_vision_upgrade
	var disable_movement_upgrade = Globals.TimeLevel == Globals.TimeMaxLevel
	if !disable_movement_upgrade:
		disable_movement_upgrade = Globals.banked_acorns < Globals.TimeCostArray[Globals.TimeLevel]
	get_node("HUD_Layer/HUD/Shop/GridContainer/Movement").disabled = disable_movement_upgrade
	var disable_speed_upgrade = Globals.SpeedLevel == Globals.SpeedMaxLevel
	if !disable_speed_upgrade:
		disable_speed_upgrade = Globals.banked_acorns < Globals.SpeedCostArray[Globals.SpeedLevel]
	get_node("HUD_Layer/HUD/Shop/GridContainer/Speed").disabled = disable_speed_upgrade
	var disable_run_home_upgrade = Globals.RunHomeLevel == Globals.RunHomeMaxLevel
	if !disable_run_home_upgrade:
		disable_run_home_upgrade = Globals.banked_acorns < Globals.RunHomeCostArray[Globals.RunHomeLevel]
	get_node("HUD_Layer/HUD/Shop/GridContainer/RunHome").disabled = disable_run_home_upgrade
	var disable_jump_upgrade = Globals.JumpLevel == Globals.JumpMaxLevel
	if !disable_jump_upgrade:
		disable_jump_upgrade = Globals.banked_acorns < Globals.JumpCostArray[Globals.JumpLevel]
	get_node("HUD_Layer/HUD/Shop/GridContainer/Jump").disabled = disable_jump_upgrade
	var disable_hibernate_upgrade = Globals.banked_acorns < Globals.HibernationCost
	get_node("HUD_Layer/HUD/Shop/GridContainer/Hibernate").disabled = disable_hibernate_upgrade	
	
func _on_den_body_entered(_body: Node2D) -> void:
	if Globals.running_home:
		await get_tree().create_timer(1.3).timeout
	else:
		await get_tree().create_timer(0.3).timeout
	if Globals.mouth_inventory != []:
		for i in Globals.mouth_inventory:
			if i == "normal":
				Globals.banked_acorns += 1
			elif i == "silver":
				Globals.banked_acorns += 3
			elif i == "golden":
				Globals.banked_acorns += 5
			Globals.perfect_score -= 1
		$HUD_Layer/HUD/Cache.update_cache()
		Globals.mouth_inventory = []
		$Drop_Off.play()

func eat():
	get_node("HUD_Layer/HUD/Shop/ColorRect/AnimatedSprite2D").play("eat", 1.0)
	get_node("Eat").play()
	
func celebrate():
	get_node("HUD_Layer/HUD/Shop/ColorRect/AnimatedSprite2D").play("joy", 1.0)
	await get_tree().create_timer(0.2).timeout
	get_node("Jump").play()
	await get_tree().create_timer(0.3).timeout
	get_node("Jump").play()
	
func sleep():
	get_node("HUD_Layer/HUD/Shop/ColorRect/AnimatedSprite2D").play("sleep", 1.0)
	await get_tree().create_timer(0.2).timeout
	get_node("HUD_Layer/HUD/Shop/ColorRect/AnimatedSprite2D").play("sleep", 0.8)
	await get_tree().create_timer(0.2).timeout
	get_node("HUD_Layer/HUD/Shop/ColorRect/AnimatedSprite2D").play("sleep", 0.6)
	await get_tree().create_timer(0.2).timeout
	get_node("HUD_Layer/HUD/Shop/ColorRect/AnimatedSprite2D").play("sleep", 0.4)
	await get_tree().create_timer(0.2).timeout
	get_node("HUD_Layer/HUD/Shop/ColorRect/AnimatedSprite2D").play("sleep", 0.2)
	
func idle():
	get_node("HUD_Layer/HUD/Shop/ColorRect/AnimatedSprite2D").play("idle", 1.0)
	
func _on_mouth_capacity_pressed() -> void:
	if !pause:
		pause = true
		button_pause_toggle(true)
		eat()
		await get_tree().create_timer(1).timeout
		Globals.banked_acorns -= Globals.MouthCapacityCostArray[Globals.MouthCapacityLevel]
		get_node("HUD_Layer/HUD/Cache").update_cache()
		celebrate()
		await get_tree().create_timer(1).timeout
		idle()
		Globals.MouthCapacityLevel += 1
		Globals.mouth_size += 1
		get_node(str("HUD_Layer/HUD/InventoryContainer/", Globals.MouthCapacityLevel)).show()
		get_node(str("HUD_Layer/HUD/InventoryContainer/", Globals.MouthCapacityLevel, "/AnimatedSprite2D")).hide()
		get_node("HUD_Layer/HUD/Shop/GridContainer/MouthCapacityCost").text = str(Globals.MouthCapacityCostArray[Globals.MouthCapacityLevel])
		button_pause_toggle(false)
		disable_relevant_buttons()
		pause = false


func _on_vision_radius_pressed() -> void:
	if !pause:
		pause = true
		button_pause_toggle(true)
		eat()
		Globals.banked_acorns -= Globals.VisionRadiusCostArray[Globals.VisionRadiusLevel]
		get_node("HUD_Layer/HUD/Cache").update_cache()
		await get_tree().create_timer(1).timeout
		celebrate()
		await get_tree().create_timer(1).timeout
		idle()
		Globals.VisionRadiusLevel += 1
		Globals.visible_radius += 1
		get_node("HUD_Layer/HUD/Shop/GridContainer/VisionRadiusCost").text = str(Globals.VisionRadiusCostArray[Globals.VisionRadiusLevel])
		button_pause_toggle(false)
		disable_relevant_buttons()
		pause = false


func _on_movement_pressed() -> void:
	if !pause:
		pause = true
		button_pause_toggle(true)
		eat()
		await get_tree().create_timer(1).timeout
		Globals.banked_acorns -= Globals.TimeCostArray[Globals.TimeLevel]
		get_node("HUD_Layer/HUD/Cache").update_cache()
		celebrate()
		await get_tree().create_timer(1).timeout
		idle()
		Globals.TimeLevel += 1
		Globals.total_time += 4.0

		get_node("HUD_Layer/HUD/Time").update_text(Globals.total_time)
		get_node("HUD_Layer/HUD/Shop/GridContainer/MovementCost").text = str(Globals.TimeCostArray[Globals.TimeLevel])
		button_pause_toggle(false)
		disable_relevant_buttons()
		pause = false

func _on_speed_pressed() -> void:
	if !pause:
		pause = true
		button_pause_toggle(true)
		eat()
		await get_tree().create_timer(1).timeout
		Globals.banked_acorns -= Globals.SpeedCostArray[Globals.SpeedLevel]
		get_node("HUD_Layer/HUD/Cache").update_cache()
		celebrate()
		await get_tree().create_timer(1).timeout
		idle()
		Globals.SpeedLevel += 1
		Globals.current_speed = Globals.SpeedAmountArray[Globals.SpeedLevel]
		get_node("HUD_Layer/HUD/Shop/GridContainer/SpeedCost").text = str(Globals.SpeedCostArray[Globals.SpeedLevel])
		button_pause_toggle(false)
		disable_relevant_buttons()
		pause = false

func _on_run_home_pressed() -> void:
	if !pause:
		pause = true
		button_pause_toggle(true)
		eat()
		await get_tree().create_timer(1).timeout
		Globals.banked_acorns -= Globals.RunHomeCostArray[Globals.RunHomeLevel]
		get_node("HUD_Layer/HUD/Cache").update_cache()
		celebrate()
		await get_tree().create_timer(1).timeout
		idle()
		Globals.RunHomeLevel += 1
		Globals.run_home_power = true
		get_node("HUD_Layer/HUD/Shop/GridContainer/RunHomeCost").text = str(Globals.RunHomeCostArray[Globals.RunHomeLevel])
		button_pause_toggle(false)
		disable_relevant_buttons()
		pause = false
		
func _on_jump_pressed() -> void:
	if !pause:
		pause = true
		button_pause_toggle(true)
		eat()
		await get_tree().create_timer(1).timeout
		Globals.banked_acorns -= Globals.JumpCostArray[Globals.JumpLevel]
		get_node("HUD_Layer/HUD/Cache").update_cache()
		celebrate()
		await get_tree().create_timer(1).timeout
		idle()
		Globals.JumpLevel += 1
		Globals.jump_power = true
		get_node("HUD_Layer/HUD/Shop/GridContainer/JumpCost").text = str(Globals.JumpCostArray[Globals.JumpLevel])
		button_pause_toggle(false)
		disable_relevant_buttons()
		pause = false
	
		
func button_pause_toggle(toggle: bool):
	get_node("HUD_Layer/HUD/Shop/Continue").disabled = toggle
	get_node("HUD_Layer/HUD/Shop/GridContainer/MouthCapacity").disabled = toggle
	get_node("HUD_Layer/HUD/Shop/GridContainer/VisionRadius").disabled = toggle
	get_node("HUD_Layer/HUD/Shop/GridContainer/Movement").disabled = toggle
	get_node("HUD_Layer/HUD/Shop/GridContainer/Speed").disabled = toggle
	get_node("HUD_Layer/HUD/Shop/GridContainer/Hibernate").disabled = toggle
	get_node("HUD_Layer/HUD/Shop/GridContainer/RunHome").disabled = toggle
	get_node("HUD_Layer/HUD/Shop/GridContainer/Jump").disabled = toggle

func game_over() -> void:
	$HUD_Layer/HUD/Days.update_days()
	get_node("HUD_Layer/HUD/Shop").hide()
	$CharacterBody2D/PlayerSprite.hide()
	$CharacterBody2D/DummySprite.show()
	$CharacterBody2D/DummySprite.animation = "celebrate"
	$CharacterBody2D/DummySprite.stop()
	$CharacterBody2D/DummySprite.frame = 1
	$HUD_Layer/HUD/Days/SnowWall.show()
	blackout_tween = create_tween()
	blackout_tween.tween_property($HUD_Layer/Blackout, "color:a", 0.0, 2.0)
	get_node("HUD_Layer/HUD/Time").update_text(Globals.total_time)
	await get_tree().create_timer(0.6).timeout
	var movement_tween = create_tween()
	movement_tween.tween_property($CharacterBody2D/DummySprite, "global_position", $DummyAim.global_position, 2.0)
	$Punt.play()
	$CharacterBody2D/DummySprite.spin()
	await get_tree().create_timer(1.5).timeout
	blackout_tween = create_tween()
	blackout_tween.tween_property($HUD_Layer/HUD/Days/SnowWall, "color:a", 0.4, 0.01)
	await get_tree().create_timer(0.2).timeout
	blackout_tween = create_tween()
	blackout_tween.tween_property($HUD_Layer/HUD/Days/SnowWall, "color:a", 0.6, 0.01)
	await get_tree().create_timer(0.2).timeout
	blackout_tween = create_tween()
	blackout_tween.tween_property($HUD_Layer/HUD/Days/SnowWall, "color:a", 0.8, 0.01)
	await get_tree().create_timer(0.2).timeout
	blackout_tween = create_tween()
	blackout_tween.tween_property($HUD_Layer/HUD/Days/SnowWall, "color:a", 1, 0.01)
	$MainTheme.stop()
	$GameOverSong.play()
	await get_tree().create_timer(2).timeout
	get_node("HUD_Layer/HUD/GameOverLabel").show()
	await get_tree().create_timer(2).timeout
	$HUD_Layer/HUD/GameOverLabel.text += str("\n\nYou ended the game \nwith ", Globals.banked_acorns, " banked acorns.")
	await get_tree().create_timer(2).timeout
	$HUD_Layer/HUD/Retry.show()
	$HUD_Layer/HUD/Retry.grab_focus()
	#$HUD_Layer/HUD/Quit.show()
	
	

func _on_hibernate_pressed() -> void:
	if !pause:
		pause = true
		button_pause_toggle(true)
		eat()
		await get_tree().create_timer(1).timeout
		Globals.banked_acorns -= Globals.HibernationCost
		get_node("HUD_Layer/HUD/Cache").update_cache()
		sleep()
		await get_tree().create_timer(1).timeout
		$MainTheme.stop()
		blackout_tween = create_tween()
		blackout_tween.tween_property($HUD_Layer/GameOverBlackout, "color:a", 0.2, 0.01)
		await get_tree().create_timer(0.2).timeout
		blackout_tween = create_tween()
		blackout_tween.tween_property($HUD_Layer/GameOverBlackout, "color:a", 0.4, 0.01)
		await get_tree().create_timer(0.2).timeout
		blackout_tween = create_tween()
		blackout_tween.tween_property($HUD_Layer/GameOverBlackout, "color:a", 0.6, 0.01)
		await get_tree().create_timer(0.2).timeout
		blackout_tween = create_tween()
		blackout_tween.tween_property($HUD_Layer/GameOverBlackout, "color:a", 0.8, 0.01)
		await get_tree().create_timer(0.2).timeout
		blackout_tween = create_tween()
		blackout_tween.tween_property($HUD_Layer/GameOverBlackout, "color:a", 1, 0.01)
		await get_tree().create_timer(0.2).timeout
		get_node("HUD_Layer/HUD/Shop/GridContainer").hide()
		$HUD_Layer/HUD/Credits.global_position = $HUD_Layer/HUD/CreditsStart.global_position
		$VictoryLullaby.play()
		var credits_mover : Tween
		credits_mover = create_tween()
		credits_mover.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		credits_mover.tween_property($HUD_Layer/HUD/Credits, "global_position", $HUD_Layer/HUD/CreditsEnd.global_position, 30).set_trans(Tween.TRANS_LINEAR)
		await get_tree().create_timer(31).timeout
		$HUD_Layer/HUD/Credits.text += str("\n\nYou hibernated with ", Globals.remaining_days - 1, " days remaining.")
		await get_tree().create_timer(2).timeout
		$HUD_Layer/HUD/Credits.text += str("\n\nYou ended the game with ", Globals.banked_acorns, " excess acorns.")
		await get_tree().create_timer(2).timeout
		if Globals.perfect_score <= 0:
			$HUD_Layer/HUD/Perfect.show()
			$HUD_Layer/HUD/Perfect/AnimatedSprite2D.play("default")
			$HUD_Layer/HUD/Perfect/AnimatedSprite2D2.play("default")
			celebrate()
		$HUD_Layer/HUD/Retry.show()
		$HUD_Layer/HUD/Retry.grab_focus()
		#$HUD_Layer/HUD/Quit.show()
		
func _on_continue_pressed() -> void:
	setup_new_day()

func return_home():
	var den_pos : Vector2 = $TileMapLayer.map_to_local(Globals.den_position)
	den_pos -= (Globals.tile_size/2)
	$CharacterBody2D._move_to_den(den_pos)
	
func _on_day_timer_timeout() -> void:
	Globals.end_of_day = true
	await get_tree().create_timer(0.5).timeout
	$CharacterBody2D/PlayerSprite.idle()
	var den_pos : Vector2 = $TileMapLayer.map_to_local(Globals.den_position)
	den_pos -= (Globals.tile_size/2)
	blackout_tween = create_tween()
	blackout_tween.tween_property($HUD_Layer/Blackout, "color:a", 0.3, 1)
	await get_tree().create_timer(1).timeout
	$CharacterBody2D._move_to_den(den_pos)
	await get_tree().create_timer(1.5).timeout
	$CharacterBody2D/PlayerSprite.fall_asleep()
	blackout_tween = create_tween()
	blackout_tween.tween_property($HUD_Layer/Blackout, "color:a", 1.0, 2.0)
	await get_tree().create_timer(2.2).timeout
	get_node("HUD_Layer/HUD/Shop/Continue").update()
	get_node("HUD_Layer/HUD/Shop").show()
	$HUD_Layer/HUD/Shop/GridContainer/MouthCapacity.grab_focus() 
	disable_relevant_buttons()
	get_node("HUD_Layer/HUD/Shop/ColorRect/AnimatedSprite2D").play("idle", 1.0)
	get_node("HUD_Layer/HUD/Time").update_text(Globals.total_time)


func _on_retry_pressed() -> void:
	Globals.new_game = true
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
