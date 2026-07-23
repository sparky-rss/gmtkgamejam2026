extends Node

signal mouth_inventory_changed(new_value)

var mouth_inventory : Array:
	set(value):
		mouth_inventory = value
		mouth_inventory_changed.emit(mouth_inventory)
		
var mouth_size : int = 2
var visible_radius : int = 3

var banked_acorns : int = 0
const tile_size : Vector2 = Vector2(32,32)
var new_game : bool = true
const days_until_winter : int = 10
var remaining_days : int
var total_moves : int = 16
var remaining_moves : int
var end_of_day : bool = false
var player_position : Vector2
var map_position : Vector2i
const den_position : Vector2i = Vector2i(0, 0)
var playable_area : Array
var tree_spots : Array
const top_left_corner : Vector2i = Vector2i(-19, -11)
const bottom_right_corner : Vector2i = Vector2i(19, 11)

const acorn_count : int = 200
const golden_acorn_count : int = 15

const big_trees_to_generate: int = 16
const little_shrubs_to_generate: int = 100

func setup():
	remaining_days = days_until_winter
	remaining_moves = total_moves
	new_game = false
