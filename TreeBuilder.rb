# Constrcuts the syntax tree
module TreeBuilder

	module_function
	# Constructs the syntax tree with a list of tokens
	def build_tree(tokens)
		root = Node.new("")
		node_stack = []
		node_stack.push(root)
		for token in tokens
			curr_node = node_stack.last
			new_node = build_node(token)
			if new_node.type == EVAL_NESTABLE
				# Start a new nesting
				node_stack.push(new_node)
			elsif new_node.type == EVAL and new_node.expression[0] == ENDEACH
				# End current nesting
				if node_stack.length > 1
					node_stack.pop()
				else
					# The nesting ended too early
					raise(SyntaxError, "Mismatched EACH-ENDEACH expression.")
				end
				next
			end
			curr_node.children.push(new_node)
		end

		# The only node left should be the root node
		if node_stack.pop() != root
			raise(SyntaxError, "Mismatched EACH-ENDEACH expression.")
		end
		return root
	end

	# Creates a node of appropriate type based on token
	def build_node(string)
		if string[0,2] == OPENEXP
			# Add other cases here as becomes necessary
			if string.include? EACH and !string.include? ENDEACH
				return EachNode.new(string)
			else
				return ExpressionNode.new(string)
			end
		else
			return HTMLNode.new(string)
		end
	end

end