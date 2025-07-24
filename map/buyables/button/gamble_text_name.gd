@tool
extends RichTextLabel

@onready var buyable_button: BuyableButton = $".."
@onready var price: RichTextLabel = $Price

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		text = "Buy " + buyable_button.buyable_name
		price.text = "%s$ - %s$" % [buyable_button.min_price, buyable_button.max_price]
