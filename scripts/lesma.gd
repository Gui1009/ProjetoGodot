extends CharacterBody2D

enum Estado { PERSEGUINDO, RECUANDO, DERROTADA }

@export var velocidade: float = 78.0
@export var vida: int = 2
@onready var visual: Node2D = $Visual
@onready var sprite: Sprite2D = $Visual/Sprite
@onready var vizinhas: Area2D = $Vizinhas

var estado := Estado.PERSEGUINDO
var jogador: Node2D
var caminho := PackedVector2Array()
var proximo_ponto := 0
var ate_recalcular := 0.0
var ate_morder := 0.0
var recuo_restante := 0.0

func _ready() -> void:
	jogador = get_tree().get_first_node_in_group("jogador") as Node2D

func _physics_process(delta: float) -> void:
	if estado == Estado.RECUANDO:
		move_and_slide()
		velocity = velocity.move_toward(Vector2.ZERO, 850.0 * delta)
		recuo_restante -= delta
		if recuo_restante <= 0.0:
			estado = Estado.PERSEGUINDO
			visual.modulate = Color.WHITE
			ate_recalcular = 0.0
		return
	if not is_instance_valid(jogador):
		jogador = get_tree().get_first_node_in_group("jogador") as Node2D
		if jogador == null:
			return
	ate_morder -= delta
	ate_recalcular -= delta
	if ate_recalcular <= 0.0:
		var mapa := get_tree().current_scene
		if mapa != null and mapa.has_method("caminho_para"):
			caminho = mapa.call("caminho_para", global_position, jogador.global_position)
		else:
			caminho = PackedVector2Array([jogador.global_position])
		proximo_ponto = 0
		ate_recalcular = randf_range(0.35, 0.55)
	while proximo_ponto < caminho.size() and global_position.distance_to(caminho[proximo_ponto]) <= 5.0:
		proximo_ponto += 1
	var direcao := Vector2.ZERO
	if proximo_ponto < caminho.size():
		direcao = global_position.direction_to(caminho[proximo_ponto])
	var distancia := global_position.distance_to(jogador.global_position)
	if distancia < 21.0:
		direcao = Vector2.ZERO
	var separacao := Vector2.ZERO
	for vizinha in vizinhas.get_overlapping_bodies():
		if vizinha != self:
			var distancia_vizinha := global_position.distance_to(vizinha.global_position)
			separacao += vizinha.global_position.direction_to(global_position) * clampf(1.0 - distancia_vizinha / 40.0, 0.0, 1.0)
	velocity = (direcao + separacao.limit_length(0.65)).limit_length(1.0) * velocidade
	move_and_slide()
	if absf(velocity.x) > 8.0:
		sprite.flip_h = velocity.x < 0.0
	if distancia <= 31.0 and ate_morder <= 0.0 and jogador.has_method("receber_dano"):
		var raio := PhysicsRayQueryParameters2D.create(global_position, jogador.global_position, collision_mask)
		raio.exclude = [get_rid(), (jogador as CollisionObject2D).get_rid()]
		if get_world_2d().direct_space_state.intersect_ray(raio).is_empty():
			ate_morder = 1.0
			jogador.call("receber_dano", 1)

func receber_golpe(dano: int, direcao: Vector2) -> void:
	if estado == Estado.DERROTADA or dano <= 0:
		return
	vida -= dano
	visual.modulate = Color(1.5, 0.70, 0.62)
	if vida <= 0:
		estado = Estado.DERROTADA
		set_physics_process(false)
		remove_from_group("inimigos")
		set_deferred("collision_layer", 0)
		queue_free()
		return
	estado = Estado.RECUANDO
	velocity = direcao.normalized() * 210.0
	recuo_restante = 0.18
