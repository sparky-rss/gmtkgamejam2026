extends Label

func update_moves():
	self.text = str("Remaining Energy: ", Globals.remaining_moves)
