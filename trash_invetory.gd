extends Control

@onready var _sweeper : Node3D = $"../Sweeper"

var path_element: Array = [	"SubViewportContainer/3DGuiElement/SubViewport/MeshInstance3d",
							"SubViewportContainer/3DGuiElement2/SubViewport/MeshInstance3d",
							"SubViewportContainer/3DGuiElement3/SubViewport/MeshInstance3d",
							"SubViewportContainer/3DGuiElement4/SubViewport/MeshInstance3d",
							"SubViewportContainer/3DGuiElement5/SubViewport/MeshInstance3d"
]

func add_trash_to_menu() -> void:
	if _sweeper.trash_list:
		for i in range(_sweeper.trash_list.size()):
			get_node(path_element[i]).set_mesh(_sweeper.trash_list[i].instantiate().get_node("MeshInstance3D").get_mesh())
			print(_sweeper.trash_list.size())

func remove_trash_of_menu() -> void:
	get_node(path_element[_sweeper.trash_list.bsearch(null, false)-1]).set_mesh(null)
	#print(_sweeper.trash_list)
