extends Label

func update_cache():
	self.text = str("Acorns Cached: ", Globals.banked_acorns)
