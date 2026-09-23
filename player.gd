extends CharacterBody2D

# ============================================================
# CONFIGURAÇÕES DO PERSONAGEM
# ============================================================

@export_group("Movimentação")
@export var velocidade_andar: float = 100.0
@export var velocidade_correr: float = 170.0
@export var forca_pulo: float = -300.0
@export var aceleracao: float = 1200.0
@export var desaceleracao: float = 1600.0

@export_group("Ações do Input Map")
# Os nomes das ações ficam separados da lógica. Normalmente não é necessário
# mudar estes nomes: o menu Configurações remapeia as teclas para o jogador.
@export var acao_esquerda: StringName = &"move_left"
@export var acao_direita: StringName = &"move_right"
@export var acao_pular: StringName = &"jump"
@export var acao_correr: StringName = &"run"

@export_group("Respawn")
@export var tempo_respawn: float = 0.35

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var esta_correndo: bool = false
var morto: bool = false
var ponto_respawn: Vector2
var gravidade: float = float(ProjectSettings.get_setting("physics/2d/default_gravity", 980.0))


func _ready() -> void:
	ponto_respawn = global_position


func _physics_process(delta: float) -> void:
	if morto:
		return

	_aplicar_gravidade(delta)
	_processar_pulo()
	_processar_movimento_horizontal(delta)
	move_and_slide()
	_atualizar_direcao_sprite()
	_atualizar_animacao()


func _aplicar_gravidade(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravidade * delta


func _processar_pulo() -> void:
	if Input.is_action_just_pressed(acao_pular) and is_on_floor():
		velocity.y = forca_pulo


func _processar_movimento_horizontal(delta: float) -> void:
	var direcao: float = Input.get_axis(acao_esquerda, acao_direita)
	esta_correndo = Input.is_action_pressed(acao_correr)

	var velocidade_atual: float = velocidade_correr if esta_correndo else velocidade_andar
	var alvo: float = direcao * velocidade_atual
	var taxa: float = aceleracao if direcao != 0.0 else desaceleracao
	velocity.x = move_toward(velocity.x, alvo, taxa * delta)


func _atualizar_direcao_sprite() -> void:
	if velocity.x > 0.0:
		sprite.flip_h = false
	elif velocity.x < 0.0:
		sprite.flip_h = true


func _atualizar_animacao() -> void:
	if morto:
		return

	if not is_on_floor():
		sprite.speed_scale = 1.0
		sprite.play("jump")
	elif absf(velocity.x) > 1.0:
		sprite.speed_scale = 1.5 if esta_correndo else 1.0
		sprite.play("run")
	else:
		sprite.speed_scale = 1.0
		sprite.play("idle")


# ============================================================
# MORTE E RESPAWN
# ============================================================

# Chamada pela Area2D Morte.
func morrer() -> void:
	if morto:
		return

	morto = true
	velocity = Vector2.ZERO
	Global.perder_vida()
	sprite.visible = false

	await get_tree().create_timer(tempo_respawn).timeout

	if not is_inside_tree():
		return

	if Global.health <= 0:
		Global.reiniciar_tentativa()
		get_tree().change_scene_to_file("res://game_over.tscn")
		return

	respawn()


func respawn() -> void:
	global_position = ponto_respawn
	velocity = Vector2.ZERO
	sprite.visible = true
	morto = false


# Preparado para checkpoints futuros.
func definir_ponto_respawn(nova_posicao: Vector2) -> void:
	ponto_respawn = nova_posicao
