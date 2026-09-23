extends Control

const CENA_MENU: String = "res://control.tscn"

const ACOES: Array[Dictionary] = [
	{"nome": "Mover para esquerda", "acao": &"move_left"},
	{"nome": "Mover para direita", "acao": &"move_right"},
	{"nome": "Pular", "acao": &"jump"},
	{"nome": "Correr", "acao": &"run"},
]

@onready var volume_slider: HSlider = %VolumeSlider
@onready var volume_valor: Label = %VolumeValor
@onready var mutar_check: CheckBox = %MutarCheck
@onready var resolucao_option: OptionButton = %ResolucaoOption
@onready var tela_cheia_check: CheckBox = %TelaCheiaCheck
@onready var lista_teclas: VBoxContainer = %ListaTeclas
@onready var aviso_tecla: Label = %AvisoTecla

var aguardando_acao: StringName = &""
var botoes_teclas: Dictionary = {}


func _ready() -> void:
	_montar_resolucoes()
	_montar_lista_teclas()
	_carregar_interface()
	_conectar_sinais()


func _unhandled_input(event: InputEvent) -> void:
	if aguardando_acao == &"":
		if event.is_action_pressed("ui_cancel"):
			_on_voltar_pressed()
			get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.pressed and not event.echo:
		# ESC cancela a captura para não prender o jogador na tela.
		if event.keycode == KEY_ESCAPE:
			_cancelar_captura()
			get_viewport().set_input_as_handled()
			return

		Settings.definir_tecla(aguardando_acao, event)
		_atualizar_texto_tecla(aguardando_acao)
		_cancelar_captura()
		get_viewport().set_input_as_handled()


func _conectar_sinais() -> void:
	volume_slider.value_changed.connect(_on_volume_changed)
	mutar_check.toggled.connect(_on_mutar_toggled)
	resolucao_option.item_selected.connect(_on_resolucao_selected)
	tela_cheia_check.toggled.connect(_on_tela_cheia_toggled)
	%RestaurarTeclas.pressed.connect(_on_restaurar_teclas_pressed)
	%Voltar.pressed.connect(_on_voltar_pressed)


func _carregar_interface() -> void:
	volume_slider.set_value_no_signal(Settings.volume_master)
	volume_valor.text = "%d%%" % int(round(Settings.volume_master))
	mutar_check.set_pressed_no_signal(Settings.audio_mutado)
	tela_cheia_check.set_pressed_no_signal(Settings.tela_cheia)
	resolucao_option.disabled = Settings.tela_cheia
	_selecionar_resolucao_atual()

	for item: Dictionary in ACOES:
		var acao: StringName = StringName(item.get("acao", &""))
		_atualizar_texto_tecla(acao)


func _montar_resolucoes() -> void:
	resolucao_option.clear()
	for tamanho in Settings.RESOLUCOES:
		resolucao_option.add_item("%d x %d" % [tamanho.x, tamanho.y])


func _selecionar_resolucao_atual() -> void:
	for i in range(Settings.RESOLUCOES.size()):
		if Settings.RESOLUCOES[i] == Settings.resolucao:
			resolucao_option.select(i)
			return
	resolucao_option.select(0)


func _montar_lista_teclas() -> void:
	for filho in lista_teclas.get_children():
		filho.queue_free()
	botoes_teclas.clear()

	for item: Dictionary in ACOES:
		var acao: StringName = StringName(item.get("acao", &""))
		var nome_exibicao: String = String(item.get("nome", "Ação"))

		var linha: HBoxContainer = HBoxContainer.new()
		linha.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var nome: Label = Label.new()
		nome.text = nome_exibicao
		nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nome.custom_minimum_size = Vector2(280, 44)

		var botao: Button = Button.new()
		botao.custom_minimum_size = Vector2(190, 44)
		botao.text = Settings.obter_texto_tecla(acao)
		botao.pressed.connect(_iniciar_captura.bind(acao))

		linha.add_child(nome)
		linha.add_child(botao)
		lista_teclas.add_child(linha)
		botoes_teclas[acao] = botao


func _iniciar_captura(acao: StringName) -> void:
	aguardando_acao = acao
	aviso_tecla.text = "Pressione uma nova tecla... (ESC cancela)"

	for valor: Variant in botoes_teclas.values():
		var botao: Button = valor as Button
		if botao != null:
			botao.disabled = true

	var botao_atual: Button = botoes_teclas.get(acao) as Button
	if botao_atual:
		botao_atual.disabled = false
		botao_atual.text = "Aguardando..."


func _cancelar_captura() -> void:
	if aguardando_acao != &"":
		_atualizar_texto_tecla(aguardando_acao)
	aguardando_acao = &""
	aviso_tecla.text = "Clique em uma tecla para remapear."

	for valor: Variant in botoes_teclas.values():
		var botao: Button = valor as Button
		if botao != null:
			botao.disabled = false


func _atualizar_texto_tecla(acao: StringName) -> void:
	var botao: Button = botoes_teclas.get(acao) as Button
	if botao:
		botao.text = Settings.obter_texto_tecla(acao)


func _on_volume_changed(valor: float) -> void:
	volume_valor.text = "%d%%" % int(round(valor))
	Settings.definir_volume_master(valor)


func _on_mutar_toggled(ativado: bool) -> void:
	Settings.definir_audio_mutado(ativado)


func _on_resolucao_selected(indice: int) -> void:
	if indice >= 0 and indice < Settings.RESOLUCOES.size():
		Settings.definir_resolucao(Settings.RESOLUCOES[indice])


func _on_tela_cheia_toggled(ativada: bool) -> void:
	Settings.definir_tela_cheia(ativada)
	resolucao_option.disabled = ativada


func _on_restaurar_teclas_pressed() -> void:
	Settings.restaurar_controles_padrao()
	for item: Dictionary in ACOES:
		var acao: StringName = StringName(item.get("acao", &""))
		_atualizar_texto_tecla(acao)
	aviso_tecla.text = "Controles restaurados para o padrão."


func _on_voltar_pressed() -> void:
	Settings.salvar()
	get_tree().change_scene_to_file(CENA_MENU)
