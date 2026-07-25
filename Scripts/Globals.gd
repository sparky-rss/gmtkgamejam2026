extends Node

signal mouth_inventory_changed(new_value)

var running_home : bool = false

var mouth_inventory : Array:
	set(value):
		mouth_inventory = value
		mouth_inventory_changed.emit(mouth_inventory)

var jump_power : bool = false
var JumpLevel : int = 0
var JumpCostArray : Array = [10, "Sold Out"]
var JumpMaxLevel : int = 1

var run_home_power : bool = false
var RunHomeLevel : int = 0
var RunHomeCostArray : Array = [25, "Sold Out"]
var RunHomeMaxLevel : int = 1

var mouth_size : int = 1
var MouthCapacityLevel : int = 0
var MouthCapacityCostArray : Array = [2, 5, 10, 25, "Sold Out"]
var MouthCapacityMaxLevel : int = 4

var visible_radius : int = 2
var VisionRadiusLevel : int = 0
var VisionRadiusCostArray : Array = [5, 15, "Sold Out"]
var VisionRadiusMaxLevel : int = 2

var total_moves : int = 16
var MovementLevel : int = 0
var MovementCostArray : Array = [2, 3, 4, 6, 8, 10, 15, 20, 25, "Sold Out"]
var MovementMaxLevel : int = 9

var total_time : float = 15.0
var TimeLevel : int = 0
var TimeCostArray : Array = [2, 2, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 8, 8, 10, "Sold Out"]
var TimeMaxLevel : int = 15

var current_speed : float = 0.5
var SpeedLevel : int = 0
var SpeedCostArray : Array = [5, 8, 12, 20, "Sold Out"]
var SpeedAmountArray : Array = [0.5, 0.45, 0.4, 0.35, 0.3]
var SpeedMaxLevel : int = 4

const HibernationCost : int = 150

const starting_acorns : int = 0
var banked_acorns : int = 0
const tile_size : Vector2 = Vector2(32,32)
var new_game : bool = true
const days_until_winter : int = 10
var remaining_days : int
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
const silver_acorn_count : int = 41
const golden_acorn_count : int = 21
var perfect_score : int = 262

const big_trees_to_generate: int = 16
const little_shrubs_to_generate: int = 100

func setup():
	remaining_days = days_until_winter
	remaining_moves = total_moves
	jump_power = false
	JumpLevel = 0
	run_home_power = false
	RunHomeLevel = 0
	mouth_size = 1
	MouthCapacityLevel = 0
	visible_radius = 2
	VisionRadiusLevel = 0
	total_time = 15.0
	TimeLevel = 0
	current_speed = 0.5
	SpeedLevel = 0
	perfect_score = 262
	banked_acorns = starting_acorns
	end_of_day = false
	new_game = false
