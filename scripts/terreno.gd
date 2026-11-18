@tool
extends TileMapLayer

@export_tool_button("Restaurar terreno original") var restaurar = montar_terreno

func montar_terreno() -> void:
	if tile_set == null:
		return
	clear()
	for y in range(80):
		for x in range(120):
			var coluna := x + 12
			var linha := y + 8
			var tile := Vector2i(coluna % 48, linha % 32)
			var espelho := 0
			if (coluna / 48) % 2 == 1:
				tile.x = 47 - tile.x
				espelho |= TileSetAtlasSource.TRANSFORM_FLIP_H
			if (linha / 32) % 2 == 1:
				tile.y = 31 - tile.y
				espelho |= TileSetAtlasSource.TRANSFORM_FLIP_V
			set_cell(Vector2i(x, y), 0, tile, espelho)
