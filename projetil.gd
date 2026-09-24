extends Area2D

@export var velocidade: float = 200.0
@export var dano: float = 20.0 # Alterado para 20.0 (20% de 100 de vida)

var direcao: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Move o projetil na direção definida
	position += direcao * velocidade * delta

# Função para definir para onde a bala deve ir
func definir_direcao(nova_direcao: Vector2) -> void:
	direcao = nova_direcao.normalized()

func _on_body_entered(body: Node2D) -> void:
	# Ignora se colidir com o próprio inimigo voador
	if body.is_in_group("inimigos") or (body is CharacterBody2D and not (body.is_in_group("player") or body.name == "Player")):
		return

	# Causa 20% de dano se atingir o Player
	if body.has_method("tomar_dano"):
		body.tomar_dano(dano)
	elif body.has_method("morrer"):
		body.morrer()
	
	# Destrói o tiro ao colidir com o Player ou cenário
	queue_free()
