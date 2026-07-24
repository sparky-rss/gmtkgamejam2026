extends Label

@onready var DayTimer = $"../../../DayTimer"

func _process(delta: float) -> void:
	if !Globals.end_of_day and !DayTimer.is_stopped():
		if DayTimer.time_left >= 9.9:
			text = "Time Remaining: %.0f" % DayTimer.time_left
		else:
			text = "Time Remaining: %.1f" % DayTimer.time_left

func update_text(time : float):
		if time >= 9.9:
			text = "Time Remaining: %.0f" % time
		else:
			text = "Time Remaining: %.1f" % time
	
