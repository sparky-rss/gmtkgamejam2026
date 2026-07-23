extends Node

var master_bus
var music_bus
var sfx_bus

var master_volume : float
var music_volume : float
var sfx_volume : float

func init_sound_system() -> void:
	master_bus = AudioServer.get_bus_index("Master")
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("Sfx")
	set_master_volume(1)
	set_music_volume(0.4)
	set_sfx_volume(1)

func set_master_volume(value : float = -1.0) -> void:
	master_volume = value
	if value == -1:
		value = get_master_volume()
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	
func set_music_volume(value : float = -1.0) -> void:
	music_volume = value
	if value == -1:
		value = get_music_volume()
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))
	
func set_sfx_volume(value : float = -1.0) -> void:
	sfx_volume = value
	if value == -1:
		value = get_sfx_volume()
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))
	
func get_master_volume() -> float:
	return master_volume
	
func get_music_volume() -> float:
	return music_volume
	
func get_sfx_volume() -> float:
	return sfx_volume
