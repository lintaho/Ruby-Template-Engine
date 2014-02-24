# Renders HTML output
module HTMLRenderer

	module_function

	# Renders the html tree- hits each node's render_output function
	def build_html(root, data)
		return root.render_output(data)
	end

	# DEBUG: recursively prints the tree in-order, should look like input file
	def print_tree(root)
		for node in root.children
			if !node.children.empty?
				print node.statement
				print_tree(node)
			else
				print node.statement
			end
		end
	end

end
