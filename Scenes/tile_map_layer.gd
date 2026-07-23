extends TileMapLayer

func map_position(input_position : Vector2) -> Vector2i:
	var local_position = self.to_local(input_position)
	var map_pos: Vector2i = local_to_map(local_position)
	return map_pos
