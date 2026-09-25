extends Area2D

@export var elemento: String = "O"
@export var molecula: String = ""


func _on_body_entered(body: Node) -> void:
	if body.name != "Player" and not body.is_in_group("player"):
		return

	if not molecula.is_empty():
		Global.adicionar_molecula(molecula)
	elif not elemento.is_empty():
		Global.adicionar_elemento(elemento)
	else:
		return

	queue_free()
