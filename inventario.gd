extends Control

@onready var items_grid = $ItemsGrid
@export var item_slot_scene: PackedScene

func abrir():
	show()

func añadir_objeto(icono: Texture):
	var slot = item_slot_scene.instantiate()
	slot.set_icon(icono)
	items_grid.add_child(slot)
