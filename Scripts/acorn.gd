extends Node2D

var state : String

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if Globals.mouth_inventory.size() < Globals.mouth_size and self.visible:
		await get_tree().create_timer(0.3).timeout
		var new_array = Globals.mouth_inventory.duplicate()
		new_array.append(state)
		Globals.mouth_inventory = new_array.duplicate()
		self.hide()
	elif state == "golden":
		for i in Globals.mouth_inventory.size():
			if Globals.mouth_inventory[i] == "normal":
				await get_tree().create_timer(0.3).timeout
				var new_array = Globals.mouth_inventory.duplicate()
				new_array[i] = "golden"
				Globals.mouth_inventory = new_array.duplicate()
				get_node("AnimatedSprite2D").play("normal")
				break								
