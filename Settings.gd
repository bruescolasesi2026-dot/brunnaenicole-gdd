extends Node

# ============================================================
# CONFIGURAÇÕES GERAIS DO JOGO
# ============================================================
# Centraliza áudio, vídeo e teclas. As preferências são salvas em:
# user://config.cfg

const CONFIG_PATH: String = "user://config.cfg"

const RESOLUCOES: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
]

# Mantemos os nomes das ações fixos internamente.
# O jogador remapeia as teclas pelo menu sem precisar alterar código.
const CONTROLES_PADRAO: Dictionary = {
	&"move_left": KEY_A,
	&"move_right": KEY_D,
	&"jump": KEY_SPACE,
	&"run": KEY_SHIFT,
	&"craft_menu": KEY_E,
}

var volume_master: float = 80.0
var audio_mutado: bool = false
var resolucao: Vector2i = Vector2i(1280, 720)
var tela_cheia: bool = false


func _ready() -> void:
	_garantir_acoes_de_entrada()
	carregar()
	aplicar_tudo()


# ============================================================
# INPUT MAP
# ============================================================

func _garantir_acoes_de_entrada() -> void:
	for chave: Variant in CONTROLES_PADRAO:
		var acao: StringName = StringName(chave)

		if not InputMap.has_action(acao):
			InputMap.add_action(acao)

		# Só cria a tecla padrão quando a ação ainda não possui evento.
		if InputMap.action_get_events(acao).is_empty():
			var codigo_padrao: int = int(CONTROLES_PADRAO[acao])
			_definir_tecla_interna(acao, codigo_padrao, true)


func definir_tecla(acao: StringName, evento: InputEventKey) -> void:
	if not InputMap.has_action(acao):
		InputMap.add_action(acao)

	# Troca somente o teclado e preserva joystick, D-Pad e analógico.
	var eventos_nao_teclado: Array[InputEvent] = []
	var eventos_atuais: Array[InputEvent] = InputMap.action_get_events(acao)

	for evento_existente: InputEvent in eventos_atuais:
		if not (evento_existente is InputEventKey):
			eventos_nao_teclado.append(evento_existente)

	InputMap.action_erase_events(acao)

	var novo_evento: InputEventKey = InputEventKey.new()
	if evento.physical_keycode != 0:
		novo_evento.physical_keycode = evento.physical_keycode
	else:
		novo_evento.keycode = evento.keycode

	InputMap.action_add_event(acao, novo_evento)

	for evento_joystick: InputEvent in eventos_nao_teclado:
		InputMap.action_add_event(acao, evento_joystick)

	salvar()


func _definir_tecla_interna(acao: StringName, codigo: int, fisica: bool) -> void:
	if not InputMap.has_action(acao):
		InputMap.add_action(acao)

	# Ao carregar/restaurar uma tecla, não remove suporte a controle.
	var eventos_nao_teclado: Array[InputEvent] = []
	var eventos_atuais: Array[InputEvent] = InputMap.action_get_events(acao)

	for evento_existente: InputEvent in eventos_atuais:
		if not (evento_existente is InputEventKey):
			eventos_nao_teclado.append(evento_existente)

	InputMap.action_erase_events(acao)

	var evento: InputEventKey = InputEventKey.new()
	if fisica:
		evento.physical_keycode = codigo
	else:
		evento.keycode = codigo

	InputMap.action_add_event(acao, evento)

	for evento_joystick: InputEvent in eventos_nao_teclado:
		InputMap.action_add_event(acao, evento_joystick)


func obter_texto_tecla(acao: StringName) -> String:
	if not InputMap.has_action(acao):
		return "Não definida"

	var eventos: Array[InputEvent] = InputMap.action_get_events(acao)
	for evento: InputEvent in eventos:
		if evento is InputEventKey:
			var evento_tecla: InputEventKey = evento as InputEventKey
			return evento_tecla.as_text().replace(" (Physical)", "")

	return "Não definida"


func restaurar_controles_padrao() -> void:
	for chave: Variant in CONTROLES_PADRAO:
		var acao: StringName = StringName(chave)
		var codigo_padrao: int = int(CONTROLES_PADRAO[acao])
		_definir_tecla_interna(acao, codigo_padrao, true)

	salvar()


# ============================================================
# ÁUDIO
# ============================================================

func definir_volume_master(valor: float) -> void:
	volume_master = clampf(valor, 0.0, 100.0)
	_aplicar_audio()
	salvar()


func definir_audio_mutado(valor: bool) -> void:
	audio_mutado = valor
	_aplicar_audio()
	salvar()


func _aplicar_audio() -> void:
	var indice_master: int = AudioServer.get_bus_index("Master")
	if indice_master < 0:
		return

	var linear: float = maxf(volume_master / 100.0, 0.0001)
	AudioServer.set_bus_volume_db(indice_master, linear_to_db(linear))
	AudioServer.set_bus_mute(indice_master, audio_mutado or volume_master <= 0.0)


# ============================================================
# VÍDEO
# ============================================================

func definir_resolucao(nova_resolucao: Vector2i) -> void:
	resolucao = nova_resolucao
	_aplicar_video()
	salvar()


func definir_tela_cheia(ativada: bool) -> void:
	tela_cheia = ativada
	_aplicar_video()
	salvar()


func _aplicar_video() -> void:
	if tela_cheia:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(resolucao)
		_centralizar_janela()


func _centralizar_janela() -> void:
	var tela: int = DisplayServer.window_get_current_screen()
	var tamanho_tela: Vector2i = DisplayServer.screen_get_size(tela)
	var posicao: Vector2i = (tamanho_tela - resolucao) / 2
	DisplayServer.window_set_position(posicao)


# ============================================================
# SALVAR / CARREGAR
# ============================================================

func salvar() -> void:
	var config: ConfigFile = ConfigFile.new()

	config.set_value("audio", "volume_master", volume_master)
	config.set_value("audio", "mutado", audio_mutado)
	config.set_value("video", "resolucao", resolucao)
	config.set_value("video", "tela_cheia", tela_cheia)

	for chave: Variant in CONTROLES_PADRAO:
		var acao: StringName = StringName(chave)
		var eventos: Array[InputEvent] = InputMap.action_get_events(acao)

		for evento: InputEvent in eventos:
			if evento is InputEventKey:
				# O cast explícito evita inferência de Variant no Godot 4.7.
				var evento_tecla: InputEventKey = evento as InputEventKey
				var fisica: bool = evento_tecla.physical_keycode != 0
				var codigo: int

				if fisica:
					codigo = int(evento_tecla.physical_keycode)
				else:
					codigo = int(evento_tecla.keycode)

				config.set_value("controles", String(acao), codigo)
				config.set_value("controles", String(acao) + "_fisica", fisica)
				break

	var erro: Error = config.save(CONFIG_PATH)
	if erro != OK:
		push_warning("Não foi possível salvar as configurações. Código: %s" % erro)


func carregar() -> void:
	var config: ConfigFile = ConfigFile.new()
	var erro: Error = config.load(CONFIG_PATH)
	if erro != OK:
		return

	var volume_salvo: Variant = config.get_value("audio", "volume_master", volume_master)
	var mutado_salvo: Variant = config.get_value("audio", "mutado", audio_mutado)
	var resolucao_salva: Variant = config.get_value("video", "resolucao", resolucao)
	var tela_cheia_salva: Variant = config.get_value("video", "tela_cheia", tela_cheia)

	volume_master = clampf(float(volume_salvo), 0.0, 100.0)
	audio_mutado = bool(mutado_salvo)
	tela_cheia = bool(tela_cheia_salva)

	if typeof(resolucao_salva) == TYPE_VECTOR2I:
		resolucao = Vector2i(resolucao_salva)

	for chave: Variant in CONTROLES_PADRAO:
		var acao: StringName = StringName(chave)
		var nome_chave: String = String(acao)

		if config.has_section_key("controles", nome_chave):
			var codigo_padrao: int = int(CONTROLES_PADRAO[acao])
			var codigo_salvo: Variant = config.get_value("controles", nome_chave, codigo_padrao)
			var fisica_salva: Variant = config.get_value("controles", nome_chave + "_fisica", true)
			var codigo: int = int(codigo_salvo)
			var fisica: bool = bool(fisica_salva)
			_definir_tecla_interna(acao, codigo, fisica)


func aplicar_tudo() -> void:
	_aplicar_audio()
	_aplicar_video()
