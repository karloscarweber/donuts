# app/views/Home.rb
class HomeLayout < Phlex::HTML
	def template
		h1(class: "centered") { yield }
	end
end