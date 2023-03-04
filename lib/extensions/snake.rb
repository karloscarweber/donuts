# Defines a to_snake, and to_snake! method on String and Symbol
# transforms a string or symbol to snake case.
class String
	def self.to_snake(string)
		string = string.to_s if string.class == Symbol
		string.to_snake()
	end
	def to_snake()
		self.gsub(/::/, '/').
		gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
		gsub(/([a-z\d])([A-Z])/,'\1_\2').
		tr("-", "_").
		downcase
	end
	def to_snake!()
		replace self.to_snake()
	end
end
class Symbol
	def to_snake()
		self.to_s.to_snake.to_sym()
	end
	def self.to_snake(symbol)
		symbol = symbol.to_s if symbol.class == Symbol
		symbol.to_snake.to_sym()
	end
end
#
# my_string = "WhateverLoser"
# my_symbol = :WhateverLoser
#
# my_string.to_snake
# my_string.to_snake!
# my_symbol.to_snake
# my_symbol = my_symbol.to_snake
