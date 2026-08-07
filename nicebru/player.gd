extends CharacterBody2D

# ============================================
# CONFIGURAÇÕES DO PERSONAGEM
# ============================================

@export var velocidade_andar: float = 100.0
@export var velocidade_correr: float = 170.0
@export var forca_pulo: float = -300.0
@export var gravidade: float = 900.0

# Referência ao nó de animação (AnimatedSprite2D)
# Coloque um AnimatedSprite2D como filho do Player com as animações:
# "idle", "run", "jump"
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var esta_correndo: bool = false


func _physics_process(delta: float) -> void:
	# Aplica gravidade quando o personagem não está no chão
	if not is_on_floor():
		velocity.y += gravidade * delta
	else:
		velocity.y = 0

	# --- Pulo (ESPAÇO) ---
	if Input.is_action_just_pressed("ui_select") and is_on_floor():
		velocity.y = forca_pulo

	# --- Correr (SHIFT) ---
	esta_correndo = Input.is_key_pressed(KEY_SHIFT)
	var velocidade_atual: float = velocidade_correr if esta_correndo else velocidade_andar

	# --- Movimento horizontal (A e D) ---
	var direcao_x: float = 0.0
	if Input.is_key_pressed(KEY_A):
		direcao_x -= 1.0
	if Input.is_key_pressed(KEY_D):
		direcao_x += 1.0

	# --- Movimento vertical, caso o jogo seja top-down (W e S) ---
	# Se o seu jogo for plataforma 2D lateral, pode remover este bloco.
	var direcao_y: float = 0.0
	if Input.is_key_pressed(KEY_W):
		direcao_y -= 1.0
	if Input.is_key_pressed(KEY_S):
		direcao_y += 1.0

	velocity.x = direcao_x * velocidade_atual

	# Se quiser movimento vertical livre (top-down), descomente a linha abaixo:
	# velocity.y = direcao_y * velocidade_atual

	move_and_slide()

	# Vira o sprite para a direção do movimento
	if direcao_x != 0:
		sprite.flip_h = direcao_x < 0

	atualizar_animacao()


func atualizar_animacao() -> void:
	if not is_on_floor():
		sprite.play("jump")
	elif velocity.x != 0:
		sprite.play("run")
		# Ajusta a velocidade da animação de run quando está correndo
		sprite.speed_scale = 1.5 if esta_correndo else 1.0
	else:
		sprite.speed_scale = 1.0
		sprite.play("idle")
