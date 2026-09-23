extends Area2D

# Símbolo químico deste coletável.
# Cada cena define o seu: H, O, C, Na, Cl...
@export var elemento: String = "O"


func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		Global.adicionar_elemento(elemento)
		queue_free()
