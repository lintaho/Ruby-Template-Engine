require 'Tokenizer'
require 'constants'
require 'TreeBuilder'
require 'HTMLRenderer'
require 'Nodes'

describe HTMLRenderer do

	it "should output basic html" do
		html = HTMLRenderer.build_html(TreeBuilder.build_tree(Tokenizer.tokenize("<html></html>")), {}).join()
		html.should == "<html></html>"
	end

	# Expression tests
	###############################################

	it "should output nothing for an empty expression" do
		html = HTMLRenderer.build_html(TreeBuilder.build_tree(Tokenizer.tokenize("<**>")),  {}).join()
		html.should == ""
	end

	it "should output variable expressions with spaces" do
		html = HTMLRenderer.build_html(TreeBuilder.build_tree(Tokenizer.tokenize("<div><*  page *></div>")), {'page' => 'title'}).join()
		html.should == "<div>title</div>"
	end

	it "should output variable expressions without spaces" do
		html = HTMLRenderer.build_html(TreeBuilder.build_tree(Tokenizer.tokenize("<div><*page*></div>")), {'page' => 'title'}).join()
		html.should == "<div>title</div>"
	end

	it "should output nested variable expressions" do
		html = HTMLRenderer.build_html(TreeBuilder.build_tree(Tokenizer.tokenize("<div><* page.title *></div>")), {'page' => {'title' => 'Home!'}}).join()
		html.should == "<div>Home!</div>"
	end

	it "should throw error with missing key" do
		lambda {HTMLRenderer.build_html(TreeBuilder.build_tree(Tokenizer.tokenize("<div><* page.something *></div>")),
		 {'page' => {'title' => 'Home!'}}).join()}.should raise_error(IndexError)
	end

	# EACH tests
	###############################################
	it "should accept EACH parameters" do
		html = HTMLRenderer.build_html(TreeBuilder.build_tree(Tokenizer.tokenize("<div><* EACH countries country *><* country *> <*ENDEACH*></div>")),
		 {'countries' => ['USA', 'Japan', 'Turkey']}).join()
		html.should == "<div>USA Japan Turkey </div>"
	end

	it "should accept EACH parameters with no body" do
		html = HTMLRenderer.build_html(TreeBuilder.build_tree(Tokenizer.tokenize("<div><* EACH countries country *><*ENDEACH*></div>")),
		 {'countries' => ['USA', 'Japan', 'Turkey']}).join()
		html.should == "<div></div>"
	end

	it "should accept EACH parameters with text and no expressions" do
		html = HTMLRenderer.build_html(TreeBuilder.build_tree(Tokenizer.tokenize("<div><* EACH countries country *>hi! <*ENDEACH*></div>")),
		 {'countries' => ['USA', 'Japan', 'Turkey']}).join()
		html.should == "<div>hi! hi! hi! </div>"
	end

	it "should throw error on mismatched EACH/ENDEACH pairs" do
		lambda{HTMLRenderer.build_html(TreeBuilder.build_tree(Tokenizer.tokenize("<div><* EACH countries country *><* country *></div>")),
		 {'countries' => ['USA', 'Japan', 'Turkey']}).join()}.should raise_error(SyntaxError)
	end

	it "should accept EACH nested EACH parameters" do
		html = HTMLRenderer.build_html(TreeBuilder.build_tree(
			Tokenizer.tokenize("<div><* EACH countries country *><*EACH country.language lang*>l: <* lang *> <*ENDEACH*> <*ENDEACH*></div>")),
		 {'countries' =>[{'language'=> ['English', 'Spanish']}, {'language' => ['Japanese']}, {'language' => ['Turkish', 'Arabic']}]}).join()
		html.should == "<div>l: English l: Spanish  l: Japanese  l: Turkish l: Arabic  </div>"
	end

	it "should accept EACH nested EACH parameters with calls to parent data" do
		html = HTMLRenderer.build_html(TreeBuilder.build_tree(
			Tokenizer.tokenize("<div><* EACH countries country *><*EACH country.language lang*><*label*> <* lang *> <*ENDEACH*> <*ENDEACH*></div>")),
		 {'label'=>'l:', 'countries' =>[{'language'=> ['English', 'Spanish']}, {'language' => ['Japanese']}, {'language' => ['Turkish', 'Arabic']}]}).join()
		html.should == "<div>l: English l: Spanish  l: Japanese  l: Turkish l: Arabic  </div>"
	end

end 