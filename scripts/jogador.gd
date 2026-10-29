extends CharacterBody2D

@export var velocidade: float = 220.0
@onready var sprite: AnimatedSprite2D = $Animacao
var lado: String = "baixo"
var tempo_parado: float = 0.0

func _physics_process(delta: float) -> void:
	var direcao := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direcao == Vector2.ZERO:
		direcao = Vector2(
			float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
			float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
		).normalized()
	velocity = direcao * velocidade
	move_and_slide()
	if direcao != Vector2.ZERO:
		tempo_parado = 0.0
		if abs(direcao.x) > abs(direcao.y):
			lado = "lado"
			sprite.flip_h = direcao.x < 0
		else:
			lado = "baixo" if direcao.y > 0 else "cima"
			sprite.flip_h = false
		sprite.play(lado)
		sprite.position.y = -14.0
	else:
		sprite.stop()
		sprite.frame = 0
		tempo_parado += delta
		sprite.position.y = -14.0 + sin(tempo_parado * 3.0) * 0.8
