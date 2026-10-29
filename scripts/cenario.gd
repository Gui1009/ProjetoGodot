@tool
extends Node2D

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	for centro in [Vector2(270, 260), Vector2(690, 260), Vector2(270, 460), Vector2(690, 460)]:
		var canto: Vector2 = centro - Vector2(96, 56)
		draw_rect(Rect2(canto + Vector2(4, 6), Vector2(194, 112)), Color(0.12, 0.19, 0.09, 0.25))
		draw_rect(Rect2(canto, Vector2(192, 112)), Color("765032"))
		draw_rect(Rect2(canto, Vector2(192, 5)), Color("d2a56a"))
		draw_rect(Rect2(canto, Vector2(5, 112)), Color("b88851"))
		draw_rect(Rect2(canto + Vector2(187, 0), Vector2(5, 112)), Color("94663b"))
		draw_rect(Rect2(canto + Vector2(0, 107), Vector2(192, 5)), Color("b88851"))
		draw_rect(Rect2(canto + Vector2(6, 6), Vector2(180, 100)), Color("62412d"))
		for linha in range(5):
			var y: float = canto.y + 17 + linha * 18
			draw_line(Vector2(canto.x + 10, y), Vector2(canto.x + 182, y), Color("795237"), 4.0)
			draw_line(Vector2(canto.x + 10, y + 4), Vector2(canto.x + 182, y + 4), Color("503525"), 2.0)
		for prego in [Vector2(3, 3), Vector2(189, 3), Vector2(3, 109), Vector2(189, 109)]:
			draw_circle(canto + prego, 1.5, Color("573d2a"))
