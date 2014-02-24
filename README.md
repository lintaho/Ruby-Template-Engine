Templating Engine
====================================

A simple templating engine for .panoramatemplate files.

To render a panoramatemplate into HTML:
	
	./templater inputfile.panoramatemplate datafile.json outputfile.html

To evaluate an expression in a panoramatemplate, wrap the expression with
'<*' and '*>'.

This engine supports variables and each loops. 
For example:
'<* foo.bar *>' will look for the corresponding JSON keys 'foo' and 'bar'.

Use each loops by marking '<* EACH arrayname variable *>' and closing with 
'<* ENDEACH *>'. This is similar to: 'for variable in arrayname do'.

=================================================
Assumptions

A few assumptions were made on desired behavior:
- Mismatched pairs of EACH and ENDEACH should not be rendered and throws a syntax error
- Valid files are passed as the arguments to program (though we do some argument validation)
- For the scope of the project, the only supported expressions in the scope of '<* expression *>' are 
	either EACH/ENDEACH or variable expressions. However, the code allows easy implementation of
	further functionality- simply subclass the ExpressionNode class.
- The HTML in the panoramatemplate is valid
- <* expression *> statements that are invalid (i.e. no data, bad syntax) should not be rendered will throw an error
- Empty <* *> statements should be acceptable and simply render nothing.

=================================================
How it Works

The template engine was built with future extensibility in mind. The script "templater" provides the entry point into
our engine.

-The Tokenizer module tokenizes a given .panoramatemplate by splitting the document on occurences of <* ... *>
	For example, tokens may be: ["<html><body><div>", "<* expr *>", "</div><aside>", "<* EACH expr *>", "</aside>" ...]
-The TreeBuilder module takes the tokens array and builds a syntax tree. Each node of the tree is either a normal 
	text node or an expression node. Expression nodes are all tokens that contain '<*' and '*>'. The type of node also 
	determines whether or not the node can be a parent of other nodes (for example, EACH nodes). ENDEACH nodes are not 
	included in the tree, as they only serve to mark the end of a parent node's scope. 
-The HTMLRenderer module takes the syntax tree and outputs the final HTML. The render behavior for each part of 
	the template is determined by the render_output method in each Node.

-In the future, to add more functionality, simply subclass the ExpressionNode class and alter the render_output method

=================================================
Testing

Basic end to end RSpec tests can be found in templater_spec.rb
