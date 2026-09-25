extends Node

signal inventario_alterado
signal molecula_criada(formula: String, quantidade: int)
signal vida_alterada(vida_atual: int)

const VIDAS_INICIAIS: int = 3
var health: int = VIDAS_INICIAIS

var crafting_automatico: bool = false

var elementos: Dictionary = {
	"H": 0,
	"O": 0,
	"C": 0,
	"Na": 0,
	"Cl": 0,
}

var moleculas: Dictionary = {}

var receitas: Dictionary = {
	"C6H12O6": {
		"nome": "Glicose",
		"elementos": {"C": 6, "H": 12, "O": 6},
		"textura": "res://glicose--removebg-preview.png",
		"prioridade": 100,
	},
	"H2O2": {
		"nome": "Água oxigenada",
		"elementos": {"H": 2, "O": 2},
		"textura": "",
		"prioridade": 40,
	},
	"CO2": {
		"nome": "Dióxido de carbono",
		"elementos": {"C": 1, "O": 2},
		"textura": "res://elementos/co2_32x32.png",
		"prioridade": 30,
	},
	"H2O": {
		"nome": "Água",
		"elementos": {"H": 2, "O": 1},
		"textura": "res://elementos/agua_h2o_32x32.png",
		"prioridade": 20,
	},
	"NaCl": {
		"nome": "Cloreto de sódio",
		"elementos": {"Na": 1, "Cl": 1},
		"textura": "res://nacl_32x32.png",
		"prioridade": 10,
	},
}

var level = null


func adicionar_elemento(simbolo: String, quantidade: int = 1) -> void:
	if simbolo.is_empty() or quantidade <= 0:
		return

	if not elementos.has(simbolo):
		elementos[simbolo] = 0

	elementos[simbolo] += quantidade

	if crafting_automatico:
		_tentar_criar_moleculas()

	inventario_alterado.emit()


func adicionar_molecula(formula: String, quantidade: int = 1) -> void:
	if formula.is_empty() or quantidade <= 0:
		return

	moleculas[formula] = int(moleculas.get(formula, 0)) + quantidade
	molecula_criada.emit(formula, int(moleculas[formula]))
	inventario_alterado.emit()


func criar_molecula(formula: String, quantidade: int = 1) -> bool:
	if not receitas.has(formula) or quantidade <= 0:
		return false

	var maximo: int = get_quantidade_maxima(formula)
	if maximo < quantidade:
		return false

	var receita: Dictionary = receitas[formula]
	var ingredientes: Dictionary = receita.get("elementos", {})

	for simbolo: Variant in ingredientes:
		var necessario: int = int(ingredientes[simbolo]) * quantidade
		elementos[simbolo] = int(elementos.get(simbolo, 0)) - necessario

	moleculas[formula] = int(moleculas.get(formula, 0)) + quantidade
	molecula_criada.emit(formula, int(moleculas[formula]))
	inventario_alterado.emit()
	return true


func get_quantidade_maxima(formula: String) -> int:
	if not receitas.has(formula):
		return 0

	var ingredientes: Dictionary = receitas[formula].get("elementos", {})
	if ingredientes.is_empty():
		return 0

	var maximo: int = 2147483647
	for simbolo: Variant in ingredientes:
		var necessario: int = int(ingredientes[simbolo])
		if necessario <= 0:
			continue
		var disponivel: int = int(elementos.get(simbolo, 0))
		maximo = mini(maximo, int(disponivel / necessario))

	if maximo == 2147483647:
		return 0
	return maximo


func get_receitas_disponiveis() -> Array[String]:
	var disponiveis: Array[String] = []
	for formula: String in get_receitas_ordenadas():
		if get_quantidade_maxima(formula) > 0:
			disponiveis.append(formula)
	return disponiveis


func get_receitas_ordenadas() -> Array[String]:
	var formulas: Array[String] = []
	for chave: Variant in receitas:
		formulas.append(String(chave))
	formulas.sort_custom(_receita_vem_antes)
	return formulas


func registrar_receita(
	formula: String,
	nome: String,
	ingredientes: Dictionary,
	textura: String = "",
	prioridade: int = 0
) -> void:
	if formula.is_empty() or ingredientes.is_empty():
		return

	for simbolo: Variant in ingredientes:
		var chave: String = String(simbolo)
		if not elementos.has(chave):
			elementos[chave] = 0

	receitas[formula] = {
		"nome": nome,
		"elementos": ingredientes.duplicate(true),
		"textura": textura,
		"prioridade": prioridade,
	}
	inventario_alterado.emit()


func _tentar_criar_moleculas() -> void:
	for formula: String in get_receitas_ordenadas():
		var quantidade: int = get_quantidade_maxima(formula)
		if quantidade > 0:
			criar_molecula(formula, quantidade)


func _receita_vem_antes(formula_a: String, formula_b: String) -> bool:
	var receita_a: Dictionary = receitas.get(formula_a, {})
	var receita_b: Dictionary = receitas.get(formula_b, {})
	var complexidade_a: int = _complexidade_receita(receita_a)
	var complexidade_b: int = _complexidade_receita(receita_b)

	if complexidade_a != complexidade_b:
		return complexidade_a > complexidade_b

	var prioridade_a: int = int(receita_a.get("prioridade", 0))
	var prioridade_b: int = int(receita_b.get("prioridade", 0))
	if prioridade_a != prioridade_b:
		return prioridade_a > prioridade_b

	return formula_a < formula_b


func _complexidade_receita(receita: Dictionary) -> int:
	var total: int = 0
	var ingredientes: Dictionary = receita.get("elementos", {})
	for quantidade: Variant in ingredientes.values():
		total += int(quantidade)
	return total


func _tem_elementos_para(ingredientes: Dictionary) -> bool:
	for simbolo: Variant in ingredientes:
		if int(elementos.get(simbolo, 0)) < int(ingredientes[simbolo]):
			return false
	return true


func _consumir_elementos(ingredientes: Dictionary) -> void:
	for simbolo: Variant in ingredientes:
		elementos[simbolo] = int(elementos.get(simbolo, 0)) - int(ingredientes[simbolo])


func get_total_elementos_soltos() -> int:
	var total: int = 0
	for quantidade: Variant in elementos.values():
		total += int(quantidade)
	return total


func perder_vida() -> void:
	health = maxi(health - 1, 0)
	vida_alterada.emit(health)


func resetar_vidas() -> void:
	health = VIDAS_INICIAIS
	vida_alterada.emit(health)


func resetar_inventario_quimico() -> void:
	for simbolo: Variant in elementos:
		elementos[simbolo] = 0
	moleculas.clear()
	inventario_alterado.emit()


func reiniciar_tentativa() -> void:
	resetar_inventario_quimico()
	resetar_vidas()


func novo_jogo() -> void:
	resetar_inventario_quimico()
	resetar_vidas()
