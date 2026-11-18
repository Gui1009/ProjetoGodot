extends Area2D

func _ao_tocar(corpo: Node2D) -> void:
	if corpo.is_in_group("jogador") and corpo.equipar_enxada():
		var camada := get_parent() as TileMapLayer
		if camada:
			camada.erase_cell.call_deferred(camada.local_to_map(position))
		else:
			queue_free()
