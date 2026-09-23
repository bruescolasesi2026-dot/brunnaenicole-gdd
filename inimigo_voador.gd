extends CharacterBody2D

@export var velocidade: float = 60.0
@export var cena_projetil: PackedScene # Arraste a cena Projetil.tscn aqui no Inspector

var player: Node2D = null

@onready var timer_tiro: Timer = $TimerTiro
@onready var ponto_de_disparo: Node2D = $PontoDeDisparo
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if sprite:
		sprite.play("fly")
		sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if player:
		# Persegue o jogador mantendo movimento no ar
		var direcao = (player.global_position - global_position).normalized()
		velocity = direcao * velocidade
		
		# Vira o sprite na direção do player
		if sprite and direcao.x != 0:
			sprite.flip_h = direcao.x < 0
			
		move_and_slide()
	else:
		velocity = Vector2.ZERO

# Função que cria e lança o tiro
func atirar() -> void:
	if player and cena_projetil:
		var novo_projetil = cena_projetil.instantiate()
		get_parent().add_child(novo_projetil)
		
		# Define a posição inicial do tiro
		novo_projetil.global_position = ponto_de_disparo.global_position
		
		# Calcula a direção em relação ao player
		var direcao_tiro = (player.global_position - ponto_de_disparo.global_position)
		novo_projetil.definir_direcao(direcao_tiro)
		
		# Toca a animação de atirar
		if sprite:
			sprite.play("shoot")

func tomar_dano() -> void:
	queue_free()

# Chamado quando uma animação (não loop) termina
func _on_animation_finished() -> void:
	if sprite and sprite.animation == "shoot":
		sprite.play("fly")

# --- SINAIS DO EDITOR ---

# Entrou na área de detecção
func _on_detection_zone_body_entered(body: Node2D) -> void:
	print("Corpo entrou na área de deteção: ", body.name) # Mostra o nome do nó no Console
	if body.is_in_group("player") or body.name == "Player":
		player = body
		if timer_tiro.is_stopped():
			timer_tiro.start()

# Saiu da área de detecção
func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		timer_tiro.stop()

# Disparado a cada ciclo do TimerTiro
func _on_timer_tiro_timeout() -> void:
	if player:
		atirar()
