extends Node
var vida: int#0
var defensa: int#1
var fuerza: int#2
var destreza: int#3
var inteligencia: int#4
var agilidad: int#5
var resistencia: int#6
var carisma: int#7
var suerte: int#8
var arcano: int#9
var mente: int#10
var fe: int#11
var monedas:int#12
var resistencia_fisica: int#13
var resistencia_magica: int#14
var resistencia_luz: int#15
var resistencia_fuego: int#16
var resistencia_veneno: int#17
var resistencia_oscuridad: int#18
var resistencia_rayo: int#19
var resistencia_frio: int#20
var almas: int#21
var mana: int# 22
var vida_maxima: int#23
var resistencia_maxima: int #24
var mana_maxima: int #25
var furza_hailidades: int #26 
var duracion_hailidades: int #27
var eficiencia_hailidades: int #28
var rango_hailidades: int #29


var dañ_impacto: int #Armas1
var dañ_cortante: int #Armas2
var dañ_perforante: int #Armas3
var dañ_fuego: int #Armas4
var dañ_frio: int #Armas5
var dañ_elecrico: int #Armas6
var dañ_veneno: int #Armas7
var dañ_magica: int #Armas8
var dañ_luz: int #Armas9
var dañ_oscuridad: int #Armas10
var dañ_rayo: int #Armas11
var prob_critica: int #Armas12
var dañ_critico: int #Armas13
var prob_estado: int #Armas14
var vel_atac: int #Armas15

enum ConjuntoDeStads {
	vida, defensa, fuerza, destreza, inteligencia, agilidad,
	 resistencia, carisma, suerte, arcano, mente, fe, monedas, resistencia_fisica,resistencia_magica,
	 resistencia_luz,resistencia_fuego,resistencia_veneno, resistencia_oscuridad,resistencia_rayo,resistencia_frio, almas
} # [100, 30, 10, 5, 5, 5, 5, 5, 5, 5, 5, 5,5]  ejemplo de como debe ser el array 

enum ArmasStads {
dañ_impacto, dañ_cortante, dañ_perforante, dañ_fuego, dañ_frio, dañ_elecrico, dañ_veneno, dañ_magica, dañ_luz,dañ_oscuridad,
prob_critica, dañ_critico, prob_estado, vel_atac
}
	
	
func obtener_stat(stats, stat_index):
	return stats[stat_index] if stat_index < stats.size() else 0

func modificar_stat(stats, stat_index, valor):
	if stat_index < stats.size():
		stats[stat_index] += valor
