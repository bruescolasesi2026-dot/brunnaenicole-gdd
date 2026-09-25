extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if not (body.is_in_group("player") or body.name == "Player"):
		return

	if body.has_method("morrer"):
		body.call_deferred("morrer")
	elif body.has_method("tomar_dano"):
		body.call_deferred("tomar_dano", 999999.0)
	else:
		get_tree().call_deferred("reload_current_scene")
