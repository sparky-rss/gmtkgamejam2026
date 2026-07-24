extends CharacterBody2D

var sprite_node_pos_tween : Tween
var sprite_node_scale_tween : Tween

func _ready() -> void:
	Globals.player_position = global_position
	var map_pos = get_parent().get_node("TileMapLayer").map_position(global_position + (Globals.tile_size/2))
	Globals.map_position = map_pos + Vector2i(-1,0)

func _physics_process(_delta: float) -> void:
	if (!sprite_node_pos_tween or !sprite_node_pos_tween.is_running()) and !Globals.end_of_day:
		if Input.is_action_pressed("move_up") and !$up.is_colliding():
			_move(Vector2(0, -1))
			get_parent().pass_time()
		elif Input.is_action_pressed("move_up") and $up.is_colliding() and !$up2.is_colliding() and !$self.is_colliding() and Globals.jump_power:
			_jump(Vector2(0, -2))
			get_parent().pass_time()
		elif Input.is_action_pressed("move_down") and !$down.is_colliding():
			_move(Vector2(0, 1))
			get_parent().pass_time()
		elif Input.is_action_pressed("move_down") and $down.is_colliding() and !$down2.is_colliding() and !$self.is_colliding()  and Globals.jump_power:
			_jump(Vector2(0, 2))
			get_parent().pass_time()
		elif Input.is_action_pressed("move_left") and !$left.is_colliding():
			_move(Vector2(-1, 0))
			$PlayerSprite.face("left")
			get_parent().pass_time()
		elif Input.is_action_pressed("move_left") and $left.is_colliding() and !$left2.is_colliding() and !$self.is_colliding()  and Globals.jump_power:
			_jump(Vector2(-2, 0))
			$PlayerSprite.face("left")
			get_parent().pass_time()
		elif Input.is_action_pressed("move_right") and !$right.is_colliding():
			_move(Vector2(1, 0))
			$PlayerSprite.face("right")
			get_parent().pass_time()
		elif Input.is_action_pressed("move_right") and $right.is_colliding() and !$right2.is_colliding() and !$self.is_colliding()  and Globals.jump_power:
			_jump(Vector2(2, 0))
			$PlayerSprite.face("right")
			get_parent().pass_time()
		elif Input.is_action_pressed("run_home") and Globals.run_home_power: 
			get_parent().return_home()
			get_parent().pass_time()

func _move(dir: Vector2):
	global_position += dir * Globals.tile_size
	Globals.player_position = global_position
	var map_pos = get_parent().get_node("TileMapLayer").map_position(global_position + (Globals.tile_size/2))
	Globals.map_position = map_pos + Vector2i(-1,0)
	$PlayerSprite.global_position -= dir * Globals.tile_size
	$PlayerSprite.run()
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($PlayerSprite, "global_position", global_position, Globals.current_speed).set_trans(Tween.TRANS_SINE)
	
func _jump(dir: Vector2):
	global_position += dir * Globals.tile_size
	Globals.player_position = global_position
	var map_pos = get_parent().get_node("TileMapLayer").map_position(global_position + (Globals.tile_size/2))
	Globals.map_position = map_pos + Vector2i(-1,0)
	$PlayerSprite.global_position -= dir * Globals.tile_size
	$PlayerSprite.run()
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	if sprite_node_scale_tween:
		sprite_node_scale_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($PlayerSprite, "global_position", global_position, Globals.current_speed).set_trans(Tween.TRANS_SINE)
	sprite_node_scale_tween = create_tween()
	sprite_node_scale_tween.tween_property($PlayerSprite, "scale", Vector2(1.2, 1.2), Globals.current_speed/2).set_trans(Tween.TRANS_SINE)
	sprite_node_scale_tween.tween_property($PlayerSprite, "scale", Vector2(1, 1), Globals.current_speed/2).set_trans(Tween.TRANS_SINE)
	
func _move_to_den(den_pos: Vector2):
	Globals.running_home = true
	var previous_position = global_position
	global_position = den_pos
	$PlayerSprite.global_position = previous_position
	if $PlayerSprite.global_position != global_position:
		$PlayerSprite.run()	
	if global_position.x < $PlayerSprite.global_position.x:
		$PlayerSprite.face("left")
	elif global_position.x > $PlayerSprite.global_position.x:
		$PlayerSprite.face("right")
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($PlayerSprite, "global_position", global_position, 1.5).set_trans(Tween.TRANS_LINEAR)
	await get_tree().create_timer(1.3).timeout
	Globals.running_home = false
