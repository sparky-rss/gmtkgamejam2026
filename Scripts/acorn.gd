extends Node2D

var state : String
var active: bool = true

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if Globals.mouth_inventory.size() < Globals.mouth_size and self.visible and active:
		await get_tree().create_timer(0.3).timeout
		var new_array = Globals.mouth_inventory.duplicate()
		new_array.append(state)
		Globals.mouth_inventory = new_array.duplicate()
		self.hide()
		active = false
		get_parent().get_node("Collect").play()
	elif state == "silver" and self.visible and active:
		for i in Globals.mouth_inventory.size():
			if Globals.mouth_inventory[i] == "normal":
				await get_tree().create_timer(0.3).timeout
				var new_array = Globals.mouth_inventory.duplicate()
				new_array[i] = "silver"
				Globals.mouth_inventory = new_array.duplicate()
				get_node("AnimatedSprite2D").play("normal")
				state = "normal"
				get_parent().get_node("Collect").play()
				return
	elif state == "golden" and self.visible and active:
		for i in Globals.mouth_inventory.size():
			if Globals.mouth_inventory[i] == "normal":
				await get_tree().create_timer(0.3).timeout
				var new_array = Globals.mouth_inventory.duplicate()
				new_array[i] = "golden"
				Globals.mouth_inventory = new_array.duplicate()
				get_node("AnimatedSprite2D").play("normal")
				state = "normal"
				get_parent().get_node("Collect").play()
				return								
		for i in Globals.mouth_inventory.size():
			if Globals.mouth_inventory[i] == "silver":
				await get_tree().create_timer(0.3).timeout
				var new_array = Globals.mouth_inventory.duplicate()
				new_array[i] = "golden"
				Globals.mouth_inventory = new_array.duplicate()
				get_node("AnimatedSprite2D").play("silver")
				state = "silver"
				get_parent().get_node("Collect").play()
				return								
