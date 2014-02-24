# Base Node class
class Node
	attr_accessor :children

	def initialize(token)
		@statement = token
		@children = []
	end

	def statement
		return @statement
	end

	# The heavy lifting
	def render_output(data)
		page = []
		for child in @children
			page.push(child.render_output(data))
		end
		return page
	end

	def type
		return TEXT
	end

end

# HTML Node class
class HTMLNode < Node

	def render_output(data)
		return self.statement
	end

end

# Node class for variables and parent class for all <* *> nodes
class ExpressionNode < Node

	def render_output(data)
		# p self.expression
		if self.expression.length > 0
			keys = self.expression[0].split('.') #foo.bar.baz
		else
			return ""
		end
		json = data 
		# Look for the value in the JSON data
		for k in keys
			if json[k]
				json = json[k]
			else
				json = lookup(data, k)
			end
		end
		return json
	end

	# The expression might be at a higher nested node level
	def lookup(data, key)
		while data['json']
			if data['json'][key]
				return data['json'][key]
			else
				data = data['json']
			end
		end
		# We should not be here!
		raise(IndexError, "No data found for key: #{key}")
	end

	def type
		return EVAL
	end

	def expression
		return @statement.match(/<\*(.*)\*>/)[1].split()
	end

end

# Node class to handle 'EACH' scenarios
class EachNode < ExpressionNode

	def render_output(data)
		# Handles case of no whitespace after <* and before *>
		comps = self.statement.match(/#{self.expression[0]}(.*)\*>/)[1].split(' ') 
		keys = comps[0].split('.') #foo.bar.baz

		json = data
		# Look for the value in the JSON data
		for k in keys
			if json[k]
				json = json[k]
			else
				json = lookup(data, k)
			end
		end

		expr = []
		# Render the children
		if !@children.empty?
			for iter in json
				for child in @children
					expr.push(child.render_output({ 'json'=> data, comps[1] => iter}))
				end
			end
		else
			return expr
		end
		return expr
	end

	def type
		return EVAL_NESTABLE
	end

end