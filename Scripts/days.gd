extends Label

func update_days():
	self.text = str("Days Until Winter: ", Globals.remaining_days)
