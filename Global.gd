extends Node

signal inventario_alterado
signal molecula_criada(formula: String, quantidade: int)
signal vida_alterada(vida_atual: int)

const VIDAS_INICIAIS: int = 3
var health: int = VIDAS_INICIAIS

# Átomos coletados que ainda não foram usados em uma molécula.
var elementos: Dictionary = {
	"H": 0,
	"O": 0,
	"C": 0,
	"Na": 0,
	"Cl": 0,
}

# Moléculas já produzidas pelo jogador.
var moleculas: Dictionary = {}

# Receitas do jogo. Para adicionar uma nova molécula, basta incluir outra entrada.
# A textura é opcional: se estiver vazia, o HUD mostra apenas a fórmula e a quantidade.
var receitas: Dictionary = {
	"H2O": {
		"nome": "Água",
		"elementos": {"H": 2, "O": 1},
		"textura": "res://elementos/agua_h2o_32x32.png",
	},
	"CO2": {
		"nome": "Dióxido de carbono",
		"elementos": {"C": 1, "O": 2},
		"textura": "res://elementos/co2_32x32.png",
	},
	"C6H12O6": {
		"nome":"Glicose",
		"elementos": {"C": 6, "H": 12, "O": 6},
		"textura": "res://elementos/C6H12O6_32x32.png",
	},
	
	# Exemplo para ampliar depois de colocar a imagem na pasta elementos:
	# "NaCl": {
	#     "nome": "Cloreto de sódio",
	#     "elementos": {"Na": 1, "Cl": 1},
	#     "textura": "res://elementos/nacl_32x32.png",
	# },
}

var level = null

func adicionar_elemento(simbolo: String, quantidade: int = 1) -> void:
	if not elementos.has(simbolo):
		elementos[simbolo] = 0

	elementos[simbolo] += quantidade
	_tentar_criar_moleculas()
	inventario_alterado.emit()


func _tentar_criar_moleculas() -> void:
	for formula in receitas:
		var receita: Dictionary = receitas[formula]
		var ingredientes: Dictionary = receita["elementos"]

		while _tem_elementos_para(ingredientes):
			_consumir_elementos(ingredientes)
			moleculas[formula] = moleculas.get(formula, 0) + 1
			molecula_criada.emit(formula, moleculas[formula])


func _tem_elementos_para(ingredientes: Dictionary) -> bool:
	for simbolo in ingredientes:
		if elementos.get(simbolo, 0) < ingredientes[simbolo]:
			return false
	return true


func _consumir_elementos(ingredientes: Dictionary) -> void:
	for simbolo in ingredientes:
		elementos[simbolo] -= ingredientes[simbolo]


func get_total_elementos_soltos() -> int:
	var total := 0
	for quantidade in elementos.values():
		total += int(quantidade)
	return total


func perder_vida() -> void:
	health = max(health - 1, 0)
	vida_alterada.emit(health)


func resetar_vidas() -> void:
	health = VIDAS_INICIAIS
	vida_alterada.emit(health)


func resetar_inventario_quimico() -> void:
	for simbolo in elementos:
		elementos[simbolo] = 0
	moleculas.clear()
	inventario_alterado.emit()


# Usado quando as vidas chegam a zero.
func reiniciar_tentativa() -> void:
	resetar_inventario_quimico()
	resetar_vidas()


# Usado ao apertar PLAY no menu: sempre inicia uma partida limpa.
func novo_jogo() -> void:
	resetar_inventario_quimico()
	resetar_vidas()
