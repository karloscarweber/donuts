# app/views/Home.rb
class Home < Phlex::HTML
	def template
		h1(class: "centered") { yield }
	end
end