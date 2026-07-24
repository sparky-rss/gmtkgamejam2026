extends Label

var day_mover : Tween

func update_days():
	text = str(Globals.remaining_days, " Days Until Winter")
	global_position = get_parent().get_node("Start").global_position
	day_mover = create_tween()
	day_mover.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	day_mover.tween_property(self, "global_position", get_parent().get_node("End").global_position, 3).set_trans(Tween.TRANS_LINEAR)
