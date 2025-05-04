extends Control

func format_usd(amount: int) -> String:
	var str_amount := str(amount)
	var result := ""
	var count := 0

	for i in range(str_amount.length() - 1, -1, -1):
		result = str_amount[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result

	return "$" + result
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$MoneyCount.text = str(format_usd(Bank.PlayerMoney))
