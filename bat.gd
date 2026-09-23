extends CharacterBody2D

const SPEED = 80.0
var player = null # Variável vazia. O morcego não sabe onde o player está ainda.

func _physics_process(delta):
	if player: # Se o player foi encontrado...
		# direction_to calcula a matemática do ângulo exato até o jogador!
		velocity = position.direction_to(player.position) * SPEED
		move_and_slide()

# Sinal conectado da DetectionZone (Área para detectar e perseguir)
func _on_detection_zone_body_entered(body):
	if body.name == "Player":
		player = body # Memoriza o corpo do player, ativando a perseguição!

func _on_detection_zone_body_exited(body):
	if body == player:
		player = null # Para de perseguir se o player sair da zona de detecção

# Sinal conectado da Hitbox/Area2D do morcego para dar dano ao encostar no Player
func _on_hitbox_body_entered(body):
	if body.has_method("morrer"):
		body.morrer()
