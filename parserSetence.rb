#encoding = utf-8

class TreeNode
	attr_reader :name, :parent, :son, :deep

	def initialize1 name, parent, deep 
		@name = name
		@parent = parent
		@son ||= []
		@deep = deep
	end
	
	def addson son
		@son << son
	end
end

def parserSetence org_setence
	current_node = nil
	head_node = nil
	setence = org_setence
	regex_left = /\A[\n|\r|\t| ]*\(([^ ]*)/m
	regex_right = /\A[\n|\r|\t| ]*([^(]*?)\)/m
	while setence =~ /\)[\t|\n| |\r]*$/ do
		if regex_left =~ setence then
			puts "+++" + $1
			if current_node == nil then
				current_node = TreeNode.new
				current_node.initialize1 "ROOT", nil, 0
				head_node = current_node
			else
				temp_node = TreeNode.new
				temp_node.initialize1 $1, current_node, current_node.deep + 1
				p current_node.deep
				current_node.addson temp_node
				current_node = temp_node
			end
			setence = $~.post_match  
		elsif regex_right =~ setence then
			puts "---" + $1
			if $1 != "" then
				temp_node = TreeNode.new
				temp_node.initialize1 $1, current_node, current_node.deep + 1
				current_node.addson temp_node
				current_node = current_node.parent
			else
				current_node = current_node.parent
			end
			setence = $~.post_match
		else
			raise RuntimeError, "Error Format: \"#{setence}\"" 
		end
	end
	
	raise RuntimeError, "Less "")"" at the end of setence" if current_node != nil
	raise RuntimeError, "Setence is not completed" if setence == org_setence
	
	text_area = showTree_text head_node
	puts text_area
	graph_area = showTree_graph head_node
	puts graph_area
	return text_area, graph_area
end

def showTree_text head_node
	if head_node.son.size == 0 then
		"#{head_node.name}"
	else
		return_text = "(#{head_node.name} "
		head_node.son.each_with_index do |son_node, index|
			if index == 0 then
				return_text += showTree_text son_node
			else
				return_text += "\n"
				son_node.deep.times { return_text += "\t"}
				return_text += showTree_text son_node
			end
		end
		return_text += ")"
	end
end

NODE_STRING = 


def showTree_graph head_node
	"nil"
	if head_node.son.size == 0 then
		<<-eos
			<li>
				<a href="#">#{head_node.name}</a>
			</li>
		eos
	else
		return_graph = <<-eos
			<li>
			<a href="#">#{head_node.name}</a>
			<ul>
		eos
		head_node.son.each do |son_node|
			return_graph += showTree_graph son_node
		end
		return_graph += "\n</ul></li>"
	end
end
