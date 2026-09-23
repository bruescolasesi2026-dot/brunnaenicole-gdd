extends Control

@onready var play_button: Button = $play
@onready var controls_button: Button = $controls
@onready var quit_button: Button = $quit


func _ready() -> void:
	# Mantém o nome do nó para não quebrar a cena antiga, mas o botão agora
	# abre a tela completa de configurações.
	controls_button.text = "configurações"
	play_button.grab_focus()


func _on_play_pressed() -> void:
	Global.novo_jogo()
	get_tree().change_scene_to_file("res://Level1.tscn")


func _on_controls_pressed() -> void:
	get_tree().change_scene_to_file("res://configuracoes.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
