extends Node

const DURACAO := 180.0
const CAMINHO_LESMA := "res://entities/lesma.tscn"
var restante := DURACAO
var intervalo_ate_onda := 0.0
var terminou := false
var entradas := PackedVector2Array()
var lesma: PackedScene
var jogador: CharacterBody2D
var ultima_entrada := -1

@onready var fim: Control = %Fim
@onready var vida_texto: Label = %Vida
@onready var tempo_texto: Label = %Tempo

func _ready() -> void:
	jogador = get_parent().get_node("Jogador")
	lesma = load(CAMINHO_LESMA)
	jogador.connect("morreu", encerrar.bind(false))
	jogador.connect("vida_alterada", atualizar_vida)
	atualizar_vida(jogador.vida, jogador.vida_maxima)
	atualizar_tempo()
	%Reiniciar.pressed.connect(reiniciar)
	entradas = get_parent().pontos_de_entrada()

func _physics_process(delta: float) -> void:
	if terminou:
		return
	restante = maxf(0.0, restante - delta)
	atualizar_tempo()
	if restante <= 0.00001:
		encerrar(true)
		return
	intervalo_ate_onda -= delta
	if intervalo_ate_onda <= 0.0:
		var progresso := 1.0 - restante / DURACAO
		var quantidade := 1 if progresso < 0.5 else 2
		if progresso > 0.84:
			quantidade = 3
		for i in range(quantidade):
			if get_tree().get_node_count_in_group("inimigos") < 32:
				criar_lesma()
		intervalo_ate_onda = lerpf(4.0, 1.65, progresso)

func atualizar_vida(atual: int, maxima: int) -> void:
	vida_texto.text = "Vida: %d/%d" % [atual, maxima]

func atualizar_tempo() -> void:
	var segundos := ceili(restante)
	tempo_texto.text = "Tempo: %d:%02d" % [segundos / 60, segundos % 60]

func criar_lesma() -> void:
	if entradas.is_empty() or not lesma:
		return
	var opcoes: Array[int] = []
	for indice in range(entradas.size()):
		var distancia := entradas[indice].distance_to(jogador.global_position)
		if distancia >= 220.0 and indice != ultima_entrada:
			opcoes.append(indice)
	if opcoes.is_empty():
		return
	var primeira := ultima_entrada == -1
	ultima_entrada = opcoes.pick_random()
	var inimigo := lesma.instantiate() as CharacterBody2D
	inimigo.position = entradas[ultima_entrada]
	if primeira:
		var rota: PackedVector2Array = get_parent().caminho_para(jogador.global_position, inimigo.position)
		var anterior := jogador.global_position
		var distancia := 260.0
		for ponto in rota:
			var trecho := anterior.distance_to(ponto)
			if trecho >= distancia:
				inimigo.position = anterior.move_toward(ponto, distancia)
				break
			distancia -= trecho
			anterior = ponto
	get_parent().add_child(inimigo)

func encerrar(vitoria: bool) -> void:
	if terminou:
		return
	if vitoria:
		restante = 0.0
		atualizar_tempo()
	terminou = true
	%Resultado.text = "Horta a salvo!" if vitoria else "As lesmas venceram"
	var segundos := floori(DURACAO - restante)
	%Resumo.text = "Você sobreviveu aos 3 minutos." if vitoria else "Você resistiu por %d:%02d." % [segundos / 60, segundos % 60]
	fim.show()
	%Reiniciar.grab_focus()
	get_tree().paused = true

func reiniciar() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
