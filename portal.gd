extends Area2D

@export_file("*.tscn") var next_scene_path: String = ""

@export_group("Condição do Portal")
@export var moleculas_requeridas: Dictionary = {
	"H2O": 1,
}


func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player" and not body.is_in_group("player"):
		return

	var faltantes: Dictionary = _obter_moleculas_faltantes()
	if faltantes.is_empty():
		call_deferred("change_level")
	else:
		exibir_aviso(faltantes)


func _obter_moleculas_faltantes() -> Dictionary:
	var faltantes: Dictionary = {}

	for formula: Variant in moleculas_requeridas:
		var quantidade_necessaria: int = maxi(int(moleculas_requeridas[formula]), 0)
		if quantidade_necessaria == 0:
			continue

		var quantidade_possuida: int = int(Global.moleculas.get(String(formula), 0))
		if quantidade_possuida < quantidade_necessaria:
			faltantes[String(formula)] = quantidade_necessaria - quantidade_possuida

	return faltantes


func change_level() -> void:
	if next_scene_path.is_empty():
		push_warning("Portal sem próxima cena configurada.")
		return

	var erro: Error = get_tree().change_scene_to_file(next_scene_path)
	if erro != OK:
		push_error("Não foi possível carregar a próxima cena: %s (erro %d)" % [next_scene_path, erro])


func exibir_aviso(faltantes: Dictionary) -> void:
	var mensagens: Array[String] = []
	for formula: Variant in faltantes:
		mensagens.append("%dx %s" % [int(faltantes[formula]), String(formula)])

	var texto: String = "Ainda falta criar: %s para abrir o portal!" % ", ".join(mensagens)
	var hud: Node = get_tree().get_first_node_in_group("hud")

	if hud != null and hud.has_method("mostrar_aviso"):
		hud.call("mostrar_aviso", texto, 3.0)
	else:
		push_warning(texto)
