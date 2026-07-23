extends Node

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

func setup():
	remaining_days = days_until_winter
	remaining_moves = total_moves
	new_game = false
