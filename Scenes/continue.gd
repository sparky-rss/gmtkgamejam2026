extends Button
 
func update():
	text = str( "Continue (", Globals.remaining_days - 1, " days remain)")
