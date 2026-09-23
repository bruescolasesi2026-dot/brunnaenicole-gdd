extends CanvasLayer

@onready var painel_pause: Control = $PainelPause

func _ready() -> void:
	painel_pause.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			_despausar()
		else:
			_pausar()

func _pausar() -> void:
	get_tree().paused = true
	painel_pause.visible = true

func _despausar() -> void:
	get_tree().paused = false
	painel_pause.visible = false

# --- SINAIS DOS BOTÕES ---

func _on_botao_continuar_pressed() -> void:
	_despausar()

func _on_botao_reiniciar_pressed() -> void:
	_despausar()
	get_tree().reload_current_scene() # Recarrega a fase atual

func _on_botao_menu_principal_pressed() -> void:
	_despausar()
	get_tree().change_scene_to_file("res://control.tscn") # Caminho para o seu Menu Principal
