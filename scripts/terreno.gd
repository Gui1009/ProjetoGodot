@tool
extends TileMapLayer

@export_tool_button("Restaurar terreno original") var restaurar = montar_terreno

func montar_terreno() -> void:
	if tile_set == null:
		return
	clear()
	for y in range(32):
		for x in range(48):
			var celula := Vector2i(x, y)
			set_cell(celula, 0, celula)
	update_internals()
