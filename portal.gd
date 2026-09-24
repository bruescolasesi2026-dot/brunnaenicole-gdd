extends Area2D

# @export_file cria um botão no Inspector para escolher o arquivo da próxima cena!
@export_file("*.tscn") var next_scene_path

@export_group("Condição do Portal")
# Dicionário de moléculas necessárias para liberar o portal.
# Exemplo de preenchimento no Inspector: {"H2O": 2, "CO2": 1}
@export var moleculas_requeridas: Dictionary = {
	"H2O": 1
}

@export_group("Interface / Feedback")
# Aceita o HUD inteiro, CanvasLayer ou o nó de Label de aviso diretamente no Inspector
@export var label_aviso: Node 


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		var faltantes_dict: Dictionary = _obter_moleculas_faltantes()
		
		# Se o dicionário de faltantes estiver vazio, o jogador tem tudo o que precisa!
		if faltantes_dict.is_empty():
			call_deferred("change_level")
		else:
			exibir_aviso(faltantes_dict)


func _obter_moleculas_faltantes() -> Dictionary:
	var faltam: Dictionary = {}
	
	for formula in moleculas_requeridas:
		var qtd_necessaria: int = int(moleculas_requeridas[formula])
		var qtd_possuida: int = int(Global.moleculas.get(formula, 0))
		
		if qtd_possuida < qtd_necessaria:
			faltam[formula] = qtd_necessaria - qtd_possuida
			
	return faltam


func change_level() -> void:
	if next_scene_path:
		get_tree().change_scene_to_file(next_scene_path)


func exibir_aviso(faltantes_dict: Dictionary) -> void:
	if not label_aviso:
		return

	# Monta a mensagem formatada com todas as moléculas que ainda faltam
	var lista_mensagens: Array = []
	for formula in faltantes_dict:
		lista_mensagens.append(str(faltantes_dict[formula]) + "x " + str(formula))
		
	var texto_mensagem: String = "Ainda falta criar: " + ", ".join(lista_mensagens) + " para abrir o portal!"

	# Procura o nó de texto correto dentro do que foi arrastado no Inspector
	var alvo_texto: Control = null

	if label_aviso is Label:
		alvo_texto = label_aviso
	elif "text" in label_aviso:
		alvo_texto = label_aviso
	else:
		alvo_texto = label_aviso.find_child("*Label*", true, false)

	# Exibe o texto no ecrã
	if alvo_texto:
		alvo_texto.text = texto_mensagem
		alvo_texto.visible = true
		
		# Esconde a mensagem automaticamente após 3 segundos
		await get_tree().create_timer(3.0).timeout
		if is_instance_valid(alvo_texto):
			alvo_texto.visible = false
