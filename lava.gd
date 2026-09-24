extends Area2D

# Conecta o sinal body_entered do nó Area2D a esta função
func _on_body_entered(body: Node2D) -> void:
	# Verifica se o corpo que entrou é o Player
	if body.is_in_group("player") or body.name == "Player":
		# Se o teu Player tiver o método de tomar dano ou morrer:
		if body.has_method("tomar_dano"):
			body.tomar_dano()
		elif body.has_method("morrer"):
			body.morrer()
		else:
			# Caso não tenhas função de vida ainda, recarrega a fase
			get_tree().reload_current_scene()
