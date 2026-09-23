extends Area2D

@export var velocidade: float = 200.0
var direcao: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Move o projetil na direção definida
	position += direcao * velocidade * delta

# Função para definir para onde a bala deve ir
func definir_direcao(nova_direcao: Vector2) -> void:
	direcao = nova_direcao.normalized()

func _on_body_entered(body: Node2D) -> void:
	# Não acerta o próprio inimigo
	if body.is_in_group("inimigos"):
		return

	# Causa dano se atingir o Player
	if body.has_method("morrer"):
		body.morrer()
	
	# Destrói o tiro ao colidir com o Player ou com o cenário
	queue_free()
