extends CanvasLayer

var painel_moleculas: HBoxContainer
var aviso_molecula: Label
var timer_aviso: Timer


func _ready() -> void:
	Global.inventario_alterado.connect(_atualizar_hud)
	Global.molecula_criada.connect(_ao_criar_molecula)
	Global.vida_alterada.connect(_ao_alterar_vida)
	_criar_area_de_moleculas()
	_atualizar_hud()


func _criar_area_de_moleculas() -> void:
	painel_moleculas = HBoxContainer.new()
	painel_moleculas.name = "Moleculas"
	painel_moleculas.position = Vector2(15, 90)
	painel_moleculas.add_theme_constant_override("separation", 12)
	add_child(painel_moleculas)

	aviso_molecula = Label.new()
	aviso_molecula.name = "AvisoMolecula"
	aviso_molecula.position = Vector2(15, 145)
	aviso_molecula.add_theme_font_size_override("font_size", 18)
	add_child(aviso_molecula)

	timer_aviso = Timer.new()
	timer_aviso.one_shot = true
	timer_aviso.wait_time = 2.5
	timer_aviso.timeout.connect(func(): aviso_molecula.text = "")
	add_child(timer_aviso)


func _atualizar_hud() -> void:
	var linhas: Array[String] = []
	linhas.append("VIDA: %d" % Global.health)

	var atomos_visiveis: Array[String] = []
	for simbolo in Global.elementos:
		var qtd: int = Global.elementos[simbolo]
		if qtd > 0:
			atomos_visiveis.append("%s:%d" % [simbolo, qtd])

	if atomos_visiveis.is_empty():
		linhas.append("ÁTOMOS: -")
	else:
		linhas.append("ÁTOMOS: " + "  ".join(atomos_visiveis))

	$ScoreText.text = "\n".join(linhas)
	_atualizar_moleculas_visuais()


func _atualizar_moleculas_visuais() -> void:
	for filho in painel_moleculas.get_children():
		filho.queue_free()

	for formula in Global.moleculas:
		var qtd: int = Global.moleculas[formula]
		if qtd <= 0:
			continue

		var bloco := VBoxContainer.new()
		bloco.custom_minimum_size = Vector2(58, 58)

		var receita: Dictionary = Global.receitas.get(formula, {})
		var caminho_textura: String = receita.get("textura", "")

		if caminho_textura != "" and ResourceLoader.exists(caminho_textura):
			var icone := TextureRect.new()
			icone.texture = load(caminho_textura)
			icone.custom_minimum_size = Vector2(40, 40)
			icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			bloco.add_child(icone)

		var texto := Label.new()
		texto.text = "%s x%d" % [formula, qtd]
		texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bloco.add_child(texto)

		painel_moleculas.add_child(bloco)


func _ao_criar_molecula(formula: String, _quantidade: int) -> void:
	var nome: String = Global.receitas.get(formula, {}).get("nome", formula)
	aviso_molecula.text = "Molécula criada: %s (%s)!" % [nome, formula]
	timer_aviso.start()
	_atualizar_hud()


func _ao_alterar_vida(_vida_atual: int) -> void:
	_atualizar_hud()
