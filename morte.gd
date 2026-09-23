extends Area2D

# Zona de queda/morte reutilizável.
# Quando um CharacterBody2D que possui o método morrer() entra na área,
# a chamada é feita de forma adiada para não alterar o estado no meio da física.

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("morrer"):
		body.call_deferred("morrer")
