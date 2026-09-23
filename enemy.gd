extends CharacterBody2D

@export var vida_maxima: int = 1
@export var velocidade: float = 60.0
@export var forca_quique: float = -200.0
@export var forca_pulo: float = -250.0  # Força do pulo acionado pelo Timer

var vida_atual: int
var gravidade: float = float(ProjectSettings.get_setting("physics/2d/default_gravity", 980.0))
var a_morrer: bool = false

@onready var player: Node2D = get_tree().get_first_node_in_group("player")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	vida_atual = vida_maxima

func _physics_process(delta: float) -> void:
	if a_morrer:
		return

	# Aplica a gravidade se o Slime não estiver no chão
	if not is_on_floor():
		velocity.y += gravidade * delta

	# Movimentação horizontal perseguindo o jogador
	if player:
		var direcao = (player.global_position.x - global_position.x)
		if direcao != 0:
			velocity.x = sign(direcao) * velocidade
			if sprite:
				sprite.flip_h = velocity.x < 0
	else:
		velocity.x = 0

	move_and_slide()

func take_damage(quantidade: int = 1) -> void:
	vida_atual -= quantidade
	if vida_atual <= 0:
		a_morrer = true
		queue_free()

func _on_hitbox_player_body_entered(body: Node2D) -> void:
	if a_morrer:
		return
		
	if body.has_method("morrer"):
		body.morrer()

func _on_head_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.has_method("morrer"):
		body.velocity.y = forca_quique
		take_damage(1)

# Função executada a cada 2.0 segundos pelo Timer
func _on_timer_timeout() -> void:
	# Só pula se o Slime estiver no chão e não estiver morrendo
	if is_on_floor() and not a_morrer:
		velocity.y = forca_pulo
