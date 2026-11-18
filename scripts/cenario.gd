@tool
extends Node2D

const ARENA := Rect2(32, 32, 1856, 1216)
const PASSO := 24
const FOLGA := 22
var grade := AStarGrid2D.new()

func _ready() -> void:
	if not Engine.is_editor_hint():
		preparar_caminhos()

func limites_arena() -> Rect2:
	return ARENA

func pontos_de_entrada() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(192, 72), Vector2(624, 72), Vector2(960, 72), Vector2(1456, 72), Vector2(1728, 72),
		Vector2(1848, 304), Vector2(1848, 640), Vector2(1848, 1008),
		Vector2(1728, 1208), Vector2(1312, 1208), Vector2(960, 1208), Vector2(528, 1208), Vector2(192, 1208),
		Vector2(72, 1008), Vector2(72, 640), Vector2(72, 304)
	])

func preparar_caminhos() -> void:
	grade.region = Rect2i(0, 0, 80, 54)
	grade.cell_size = Vector2(PASSO, PASSO)
	grade.offset = grade.cell_size * 0.5
	grade.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grade.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	grade.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	grade.update()
	var barreiras: Array[Rect2] = []
	for camada: TileMapLayer in [$Canteiros, $Cerca]:
		for celula in camada.get_used_cells():
			var tile := camada.get_cell_tile_data(celula)
			var centro := camada.map_to_local(celula)
			for i in range(tile.get_collision_polygons_count(0)):
				var pontos := tile.get_collision_polygon_points(0, i)
				var caixa := Rect2(camada.to_global(centro + pontos[0]), Vector2.ZERO)
				for ponto in pontos:
					caixa = caixa.expand(camada.to_global(centro + ponto))
				barreiras.append(caixa.grow(FOLGA))
	var interior := ARENA.grow(-FOLGA)
	for y in range(grade.region.size.y):
		for x in range(grade.region.size.x):
			var id := Vector2i(x, y)
			var ponto := grade.get_point_position(id)
			var bloqueado := not interior.has_point(ponto)
			for barreira in barreiras:
				if barreira.has_point(ponto):
					bloqueado = true
					break
			grade.set_point_solid(id, bloqueado)

func celula_livre(ponto: Vector2) -> Vector2i:
	var id := Vector2i((ponto / PASSO).floor()).clamp(Vector2i.ZERO, grade.region.end - Vector2i.ONE)
	if not grade.is_point_solid(id):
		return id
	for raio in range(1, 10):
		var melhor := Vector2i(-1, -1)
		var distancia := INF
		for y in range(id.y - raio, id.y + raio + 1):
			for x in range(id.x - raio, id.x + raio + 1):
				var vizinha := Vector2i(x, y)
				if not grade.region.has_point(vizinha) or grade.is_point_solid(vizinha):
					continue
				var d := grade.get_point_position(vizinha).distance_squared_to(ponto)
				if d < distancia:
					melhor = vizinha
					distancia = d
		if melhor.x >= 0:
			return melhor
	return Vector2i(-1, -1)

func caminho_para(origem: Vector2, destino: Vector2) -> PackedVector2Array:
	var inicio := celula_livre(origem)
	var fim := celula_livre(destino)
	if inicio.x < 0 or fim.x < 0:
		return PackedVector2Array()
	var pontos := grade.get_point_path(inicio, fim)
	if pontos.is_empty():
		return pontos
	if pontos.size() > 1 and Vector2i((origem / PASSO).floor()) == inicio:
		pontos.remove_at(0)
	if Vector2i((destino / PASSO).floor()) == fim:
		pontos.append(destino)
	return pontos
