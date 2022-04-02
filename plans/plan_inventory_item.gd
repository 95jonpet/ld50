extends TextureRect

@onready var border: ReferenceRect = $ReferenceRect


func initialize(new_texture: Texture) -> void:
	self.texture = new_texture


func select() -> void:
	border.show()


func deselect() -> void:
	border.hide()
