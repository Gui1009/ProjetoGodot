@tool
extends StaticBody2D

const ATLAS := preload("res://sprites/atlas.png")
@export_enum("Repolho", "Cenoura", "Mudas", "Misto") var cultivo := 0:
	set(valor):
		cultivo = valor
		queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-92, -46, 192, 104), Color(0.14, 0.15, 0.09, 0.30))
	draw_rect(Rect2(-96, -52, 192, 104), Color("694631"))
	draw_rect(Rect2(-96, -52, 192, 5), Color("d2aa73"))
	draw_rect(Rect2(-96, -48, 5, 97), Color("b78d59"))
	draw_rect(Rect2(91, -48, 5, 97), Color("967146"))
	draw_rect(Rect2(-96, 47, 192, 3), Color("bb905d"))
	draw_rect(Rect2(-91, -47, 182, 94), Color("62412c"))
	for linha in range(5):
		var y := -39 + linha * 18
		draw_rect(Rect2(-86, y, 172, 3), Color("805538"))
		draw_rect(Rect2(-85, y + 4, 170, 2), Color("513726"))
	for y in [-50, 48]:
		for x in [-93, 92]:
			draw_rect(Rect2(x, y, 2, 2), Color("513b2c"))
	for linha in range(2):
		for i in range(5):
			var planta := cultivo if cultivo != 3 else (linha + i) % 2
			var escala := 29.0 + (linha * 7 + i * 3 + cultivo) % 8
			var centro := Vector2(-66 + i * 33 + linha * 3, -19 + linha * 36)
			var tamanho := Vector2(escala, escala * 276 / 313.5)
			draw_texture_rect_region(ATLAS, Rect2(centro - tamanho * 0.5, tamanho), Rect2(planta * 313.5, 978, 313.5, 276))
