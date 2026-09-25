extends CanvasLayer

@onready var aviso_portal: Label = $Control/AvisoLabel

var painel_moleculas: HBoxContainer
var aviso_molecula: Label
var timer_aviso: Timer
var timer_aviso_portal: Timer
var prompt_crafting: Label
var painel_crafting: PanelContainer
var lista_receitas: VBoxContainer
var atomos_crafting: Label
var crafting_aberto: bool = false
var crafting_pausou_jogo: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("hud")

	var cena_atual: Node = get_tree().current_scene
	if cena_atual != null and not cena_atual.scene_file_path.is_empty():
		Global.level = cena_atual.scene_file_path

	Global.inventario_alterado.connect(_ao_alterar_inventario)
	Global.molecula_criada.connect(_ao_criar_molecula)
	Global.vida_alterada.connect(_ao_alterar_vida)

	_criar_area_de_moleculas()
	_criar_interface_crafting()
	_configurar_aviso_portal()
	_atualizar_hud()


func _input(event: InputEvent) -> void:
	if crafting_aberto:
		if event.is_action_pressed("craft_menu") or event.is_action_pressed("ui_cancel"):
			_fechar_crafting()
			get_viewport().set_input_as_handled()
		return

	if get_tree().paused:
		return

	if event.is_action_pressed("craft_menu"):
		_abrir_crafting()
		get_viewport().set_input_as_handled()


func _configurar_aviso_portal() -> void:
	aviso_portal.visible = false
	aviso_portal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aviso_portal.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	aviso_portal.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	aviso_portal.custom_minimum_size = Vector2(540, 70)
	aviso_portal.offset_left = -270.0
	aviso_portal.offset_top = -35.0
	aviso_portal.offset_right = 270.0
	aviso_portal.offset_bottom = 35.0

	timer_aviso_portal = Timer.new()
	timer_aviso_portal.one_shot = true
	timer_aviso_portal.timeout.connect(_ocultar_aviso_portal)
	add_child(timer_aviso_portal)


func mostrar_aviso(texto: String, duracao: float = 3.0) -> void:
	if texto.is_empty():
		return

	aviso_portal.text = texto
	aviso_portal.visible = true
	timer_aviso_portal.start(maxf(duracao, 0.1))


func _ocultar_aviso_portal() -> void:
	aviso_portal.visible = false


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

	prompt_crafting = Label.new()
	prompt_crafting.name = "PromptCrafting"
	prompt_crafting.position = Vector2(15, 178)
	prompt_crafting.add_theme_font_size_override("font_size", 17)
	add_child(prompt_crafting)

	timer_aviso = Timer.new()
	timer_aviso.one_shot = true
	timer_aviso.wait_time = 2.5
	timer_aviso.timeout.connect(_limpar_aviso_molecula)
	add_child(timer_aviso)


func _limpar_aviso_molecula() -> void:
	aviso_molecula.text = ""


func _criar_interface_crafting() -> void:
	painel_crafting = PanelContainer.new()
	painel_crafting.name = "PainelCrafting"
	painel_crafting.set_anchors_preset(Control.PRESET_CENTER)
	painel_crafting.offset_left = -270.0
	painel_crafting.offset_top = -235.0
	painel_crafting.offset_right = 270.0
	painel_crafting.offset_bottom = 235.0
	painel_crafting.visible = false
	add_child(painel_crafting)

	var margem: MarginContainer = MarginContainer.new()
	margem.add_theme_constant_override("margin_left", 24)
	margem.add_theme_constant_override("margin_top", 20)
	margem.add_theme_constant_override("margin_right", 24)
	margem.add_theme_constant_override("margin_bottom", 20)
	painel_crafting.add_child(margem)

	var coluna: VBoxContainer = VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 10)
	margem.add_child(coluna)

	var titulo: Label = Label.new()
	titulo.text = "COMBINAÇÕES QUÍMICAS"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 26)
	coluna.add_child(titulo)

	atomos_crafting = Label.new()
	atomos_crafting.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	atomos_crafting.add_theme_font_size_override("font_size", 17)
	coluna.add_child(atomos_crafting)

	var separador: HSeparator = HSeparator.new()
	coluna.add_child(separador)

	var rolagem: ScrollContainer = ScrollContainer.new()
	rolagem.custom_minimum_size = Vector2(490, 295)
	coluna.add_child(rolagem)

	lista_receitas = VBoxContainer.new()
	lista_receitas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista_receitas.add_theme_constant_override("separation", 7)
	rolagem.add_child(lista_receitas)

	var instrucoes: Label = Label.new()
	instrucoes.text = "↑/↓ selecionar   •   ENTER/A criar   •   ESC/B voltar"
	instrucoes.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instrucoes.add_theme_font_size_override("font_size", 15)
	coluna.add_child(instrucoes)


func _ao_alterar_inventario() -> void:
	_atualizar_hud()
	if crafting_aberto:
		_atualizar_lista_crafting.call_deferred()


func _atualizar_hud() -> void:
	var linhas: Array[String] = []
	linhas.append("VIDA: %d" % Global.health)

	var atomos_visiveis: Array[String] = []
	for simbolo: Variant in Global.elementos:
		var quantidade: int = int(Global.elementos[simbolo])
		if quantidade > 0:
			atomos_visiveis.append("%s:%d" % [String(simbolo), quantidade])

	if atomos_visiveis.is_empty():
		linhas.append("ÁTOMOS: -")
	else:
		linhas.append("ÁTOMOS: " + "  ".join(atomos_visiveis))

	$ScoreText.text = "\n".join(linhas)
	_atualizar_moleculas_visuais()
	_atualizar_prompt_crafting()


func _atualizar_prompt_crafting() -> void:
	var disponiveis: int = Global.get_receitas_disponiveis().size()
	var tecla: String = Settings.obter_texto_tecla(&"craft_menu")

	if disponiveis == 1:
		prompt_crafting.text = "%s / START: COMBINAÇÕES • 1 disponível" % tecla
	else:
		prompt_crafting.text = "%s / START: COMBINAÇÕES • %d disponíveis" % [tecla, disponiveis]


func _atualizar_moleculas_visuais() -> void:
	_limpar_container(painel_moleculas)

	for formula: Variant in Global.moleculas:
		var quantidade: int = int(Global.moleculas[formula])
		if quantidade <= 0:
			continue

		var bloco: VBoxContainer = VBoxContainer.new()
		bloco.custom_minimum_size = Vector2(64, 58)

		var receita: Dictionary = Global.receitas.get(formula, {})
		var caminho_textura: String = String(receita.get("textura", ""))

		if not caminho_textura.is_empty() and ResourceLoader.exists(caminho_textura):
			var textura: Texture2D = load(caminho_textura) as Texture2D
			if textura != null:
				var icone: TextureRect = TextureRect.new()
				icone.texture = textura
				icone.custom_minimum_size = Vector2(40, 40)
				icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				bloco.add_child(icone)

		var texto: Label = Label.new()
		texto.text = "%s x%d" % [String(formula), quantidade]
		texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bloco.add_child(texto)

		painel_moleculas.add_child(bloco)


func _abrir_crafting() -> void:
	if crafting_aberto:
		return

	crafting_aberto = true
	crafting_pausou_jogo = not get_tree().paused
	if crafting_pausou_jogo:
		get_tree().paused = true

	painel_crafting.visible = true
	_atualizar_lista_crafting()


func _fechar_crafting() -> void:
	if not crafting_aberto:
		return

	crafting_aberto = false
	painel_crafting.visible = false

	if crafting_pausou_jogo:
		get_tree().paused = false
	crafting_pausou_jogo = false


func _atualizar_lista_crafting() -> void:
	if not crafting_aberto or lista_receitas == null:
		return

	_limpar_container(lista_receitas)
	atomos_crafting.text = "Átomos disponíveis: " + _texto_atomos()

	var primeiro_disponivel: Button = null
	for formula: String in Global.get_receitas_ordenadas():
		var receita: Dictionary = Global.receitas.get(formula, {})
		var nome: String = String(receita.get("nome", formula))
		var ingredientes: Dictionary = receita.get("elementos", {})
		var maximo: int = Global.get_quantidade_maxima(formula)

		var botao: Button = Button.new()
		botao.custom_minimum_size = Vector2(465, 48)
		botao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		botao.text = "%s (%s)   •   %s   •   possível: %d" % [
			nome,
			formula,
			_texto_ingredientes(ingredientes),
			maximo,
		]
		botao.disabled = maximo <= 0
		botao.pressed.connect(_criar_receita.bind(formula))
		lista_receitas.add_child(botao)

		if primeiro_disponivel == null and not botao.disabled:
			primeiro_disponivel = botao

	if primeiro_disponivel != null:
		primeiro_disponivel.call_deferred("grab_focus")


func _criar_receita(formula: String) -> void:
	Global.criar_molecula(formula)


func _limpar_container(container: Node) -> void:
	for filho: Node in container.get_children():
		container.remove_child(filho)
		filho.queue_free()


func _texto_atomos() -> String:
	var partes: Array[String] = []
	for simbolo: Variant in Global.elementos:
		var quantidade: int = int(Global.elementos[simbolo])
		if quantidade > 0:
			partes.append("%s:%d" % [String(simbolo), quantidade])

	if partes.is_empty():
		return "nenhum"
	return "  ".join(partes)


func _texto_ingredientes(ingredientes: Dictionary) -> String:
	var partes: Array[String] = []
	for simbolo: Variant in ingredientes:
		partes.append("%s×%d" % [String(simbolo), int(ingredientes[simbolo])])
	return " + ".join(partes)


func _ao_criar_molecula(formula: String, _quantidade: int) -> void:
	var receita: Dictionary = Global.receitas.get(formula, {})
	var nome: String = String(receita.get("nome", formula))
	aviso_molecula.text = "Molécula criada: %s (%s)!" % [nome, formula]
	timer_aviso.start()


func _ao_alterar_vida(_vida_atual: int) -> void:
	_atualizar_hud()
