extends Area2D

@export var velocidade_afundar: float = 30.0 # Velocidade com que o jogador cai na areia
@export var desaceleracao_horizontal: float = 0.3 # Reduz o movimento lateral (30% da velocidade normal)

var player_na_areia: Node2D = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	if player_na_areia:
		# Se o jogador estiver na areia, forçamos uma velocidade constante para baixo
		if "velocity" in player_na_areia:
			# Limita a velocidade de queda para parecer que está a afundar devagar
			player_na_areia.velocity.y = min(player_na_areia.velocity.y, velocidade_afundar)
			# Diminui a velocidade de andar para os lados
			player_na_areia.velocity.x *= desaceleracao_horizontal


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		player_na_areia = body


func _on_body_exited(body: Node2D) -> void:
	if body == player_na_areia:
		player_na_areia = null
