# Tokenizes a .panoramatemplate document
module Tokenizer

	module_function

	def tokenize(content)
		tokens = []
		for piece in content.split(/(<\*.*?\*>)/)
			# Ignore empty ones
			if piece == ""
				next
			end
			tokens.push(piece)
		end
		# e.g. tokens=["<html><body><div>", "<* expr *>", "</div><aside>", "<* EACH expr *>", "</aside>" ...]
		return tokens
	end

end