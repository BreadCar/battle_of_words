extends Interactable

var word_list = ["第一个词", "第二个词", "第三个词"]
var current_index = 0
var current_word = word_list[current_index]

var Line: String = "这是第一个石头的信息，其中可改变的部分是 %s" % current_word

func interact() -> void:
	# Cycle to next word
	current_index = (current_index + 1) % word_list.size()
	current_word = word_list[current_index]
	Line = "这是第二个石头的信息，其中可改变的部分是 %s" % current_word
	
	# Emit signal with updated Line
	interacted.emit(Line)
