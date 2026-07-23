extends Node2D

var blackout_tween : Tween
const acorn_scene = preload("res://Scenes/acorn.tscn")

func _ready() -> void:
	if Globals.new_game:
		Globals.setup()
		setup_first_day()
	Globals.mouth_inventory_changed.connect(mouth_inventory_update)

func mouth_inventory_update(new_mouth_inventory : Array):
	if new_mouth_inventory == []:
		for i in Globals.mouth_size:
			var target_container = str("HUD_Layer/HUD/Label/InventoryContainer/",i,"/AnimatedSprite2D")
			var target_node = get_node(target_container)
			target_node.hide()
	else:
		for i in new_mouth_inventory.size():
			var target_container = str("HUD_Layer/HUD/Label/InventoryContainer/",i,"/AnimatedSprite2D")
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
	var total_acorn_count = Globals.acorn_count + Globals.golden_acorn_count
	for i in total_acorn_count:
		var new_acorn = acorn_scene.instantiate()
		var acorn_pos : Vector2 = $TreeLayer.map_to_local(open_spots[i])
		var global_acorn_pos = to_global(acorn_pos)
		new_acorn.global_position = global_acorn_pos + Vector2(17,23)
		add_child(new_acorn)
		if i >= Globals.acorn_count:
			new_acorn.get_node(("AnimatedSprite2D")).play("golden", 1.0)
			new_acorn.state = "golden"
		else:
			new_acorn.get_node(("AnimatedSprite2D")).play("normal", 1.0)
			new_acorn.state = "normal"

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
		await get_tree().create_timer(0.5).timeout
		$CharacterBody2D/PlayerSprite.idle()
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
		


func _on_den_body_entered(_body: Node2D) -> void:
	if Globals.end_of_day:
		await get_tree().create_timer(1.3).timeout
	else:
		await get_tree().create_timer(0.3).timeout
	if Globals.mouth_inventory != []:
		for i in Globals.mouth_inventory:
			if i == "normal":
				Globals.banked_acorns += 1
			elif i == "golden":
				Globals.banked_acorns += 5
		$HUD_Layer/HUD/Cache.update_cache()
		Globals.mouth_inventory = []
