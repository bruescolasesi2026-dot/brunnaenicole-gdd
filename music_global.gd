extends AudioStreamPlayer2D

# Altere estes caminhos para os nomes exatos dos arquivos das suas fases
const FASES_COM_MUSICA = [
	"res://Level1.tscn,",
	"res://level_2.tscn",
	"res://fase_3.tscn",
]

func mudar_de_fase(caminho_da_proxima_fase: String):
	# Se a próxima fase estiver na lista, a música continua tocando de onde parou
	if caminho_da_proxima_fase in FASES_COM_MUSICA:
		if not playing:
			play()
	else:
		stop() # Se for Menu ou outra fase fora da lista, a música para
		
	get_tree().change_scene_to_file(caminho_da_proxima_fase)
