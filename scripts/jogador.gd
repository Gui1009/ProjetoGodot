extends CharacterBody2D

signal vida_alterada(atual: int, maxima: int)
signal morreu

@export var velocidade: float = 220.0
@export_range(1, 10) var vida_maxima: int = 5

const DURACAO_GOLPE := 0.22
const IMPACTO := 0.10
const RECARGA := 0.45
const ALCANCE := 68.0
const SEMIANGULO := 70.0
const IMUNIDADE := 1.15

@onready var sprite: AnimatedSprite2D = $Animacao
@onready var enxada: Node2D = $Enxada
@onready var camera: Camera2D = $Camera
var vida: int
var frente := Vector2.DOWN
var mira := Vector2.DOWN
var tem_enxada := false
var tempo_golpe := DURACAO_GOLPE
var recarga := 0.0
var imunidade := 0.0

func _ready() -> void:
	vida = vida_maxima
	var arena := get_parent()
	if arena.has_method("limites_arena"):
		var limites: Rect2 = arena.limites_arena().grow(28.0)
		camera.limit_left = floori(limites.position.x)
		camera.limit_top = floori(limites.position.y)
		camera.limit_right = ceili(limites.end.x)
		camera.limit_bottom = ceili(limites.end.y)
		camera.reset_smoothing()

func _physics_process(delta: float) -> void:
	var direcao := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direcao == Vector2.ZERO:
		direcao = Vector2(
			float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
			float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
		).normalized()
	if direcao != Vector2.ZERO and tempo_golpe >= DURACAO_GOLPE:
		frente = direcao
	recarga = maxf(0.0, recarga - delta)
	if tem_enxada and recarga <= 0.0 and Input.is_action_pressed("atacar"):
		iniciar_golpe()
	velocity = direcao * velocidade
	move_and_slide()
	animar(direcao)
	if tempo_golpe < DURACAO_GOLPE:
		atualizar_golpe(delta)
	elif tem_enxada:
		segurar_enxada()
	if imunidade > 0.0:
		imunidade = maxf(0.0, imunidade - delta)
		sprite.modulate = Color(1.0, 0.65, 0.55) if imunidade > IMUNIDADE - 0.2 else Color.WHITE

func animar(movimento: Vector2) -> void:
	var lado: StringName = &"lado"
	sprite.flip_h = false
	if absf(frente.x) > absf(frente.y):
		sprite.flip_h = frente.x < 0
	else:
		lado = &"baixo" if frente.y >= 0 else &"cima"
	sprite.animation = lado
	if movimento != Vector2.ZERO:
		sprite.play(lado)
	else:
		sprite.stop()
		sprite.frame = 0

func equipar_enxada() -> bool:
	if vida <= 0 or tem_enxada:
		return false
	tem_enxada = true
	enxada.show()
	segurar_enxada()
	return true

func segurar_enxada() -> void:
	var esquerda := frente.x < -0.4
	enxada.position = Vector2(-10 if esquerda else 10, -8)
	enxada.rotation = deg_to_rad(140 if esquerda else 40)
	enxada.scale = Vector2(0.7, -0.7 if esquerda else 0.7)
	enxada.z_index = 0

func iniciar_golpe() -> void:
	mira = frente
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var ponteiro := get_local_mouse_position()
		if ponteiro.length_squared() > 1.0:
			mira = ponteiro.normalized()
	frente = mira
	recarga = RECARGA
	tempo_golpe = 0.0
	enxada.scale = Vector2.ONE
	enxada.z_index = -1 if mira.y < -0.5 else 1
	enxada.position = Vector2(0, -9) + mira * 8.0

func atualizar_golpe(delta: float) -> void:
	var anterior := tempo_golpe
	tempo_golpe = minf(DURACAO_GOLPE, tempo_golpe + delta)
	var progresso := tempo_golpe / DURACAO_GOLPE
	enxada.rotation = mira.angle() + deg_to_rad(lerpf(-62.0, 62.0, progresso))
	if anterior < IMPACTO and tempo_golpe >= IMPACTO:
		atingir_inimigos()
	if tempo_golpe >= DURACAO_GOLPE:
		segurar_enxada()

func atingir_inimigos() -> void:
	var espaco := get_world_2d().direct_space_state
	for inimigo in get_tree().get_nodes_in_group("inimigos"):
		var distancia: Vector2 = inimigo.global_position - global_position
		if distancia.length_squared() > ALCANCE * ALCANCE:
			continue
		if distancia.length_squared() > 1.0 and mira.dot(distancia.normalized()) < cos(deg_to_rad(SEMIANGULO)):
			continue
		var raio := PhysicsRayQueryParameters2D.create(global_position, inimigo.global_position, 1)
		raio.hit_from_inside = true
		if espaco.intersect_ray(raio).is_empty():
			var empurrao := distancia.normalized() if distancia.length_squared() > 1.0 else mira
			inimigo.receber_golpe(1, empurrao)

func receber_dano(quantidade: int) -> void:
	if quantidade <= 0 or imunidade > 0.0 or vida <= 0:
		return
	vida = maxi(0, vida - quantidade)
	imunidade = IMUNIDADE
	vida_alterada.emit(vida, vida_maxima)
	if vida == 0:
		set_physics_process(false)
		velocity = Vector2.ZERO
		enxada.hide()
		sprite.stop()
		morreu.emit()
