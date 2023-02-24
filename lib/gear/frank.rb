# Extension to make sinatra style routes helper.
module FrankStyle

	# Make a camping route provided with a method type, a route, an optional app, and
	# a required block:
	#
	#   get '/another/thing' do
	#     render :another_view
	#   end
	#
	# Calling the shorthand make route helper methods inside of an app module, adds
	# The route to that App. If you don't have any apps yet, then an app named Frank
	# will be made for you.
	def self.make_camping_route(method, route, app="Frank", &block)
		meth = method.to_s

		inf = caller.first.split(":")
		file_name, line_number = inf[0], inf[1]

		s = ""
		splitted = route.split("/").each(&:capitalize!).each{|t|s<< t}
		symbol = s.to_sym

		if Camping::Apps.count == 0
			# In the case of a naked sinatra style invokation
			Camping.goes :Frank
			m = Camping::Apps.first
		elsif app != "Frank"
			# In the case of invoking sinatra style in Camping App Module
			selected = Camping::Apps.select { |a| a.name == app }
			if selected.count > 0
				m = selected.first
			else
				raise "You're trying to make a route for an app that doesn't exist. App Name: #{app}. Apps: #{Camping::Apps}."
			end
		else
			m = Camping::Apps.first
		end

		begin
			m.module_eval(%Q[
			module Controllers
				class #{meth.capitalize}#{symbol.to_s} < R '#{route}'
				end
			end
			], file_name, line_number.to_i)
		rescue => error
			if error.message.include? "superclass mismatch for class"
				raise "You've probably tried to define the same route twice using the sinatra method. ['#{route}']"
			else
				raise error
			end
		end

		m::X.const_get("#{meth.capitalize}#{symbol.to_s}").define_method(meth, &block)

		return nil
	end

	module ClassMethods
		def get(route, &block)     FrankStyle.make_camping_route('get', route, self.name, &block) end
		def put(route, &block)     FrankStyle.make_camping_route('put', route, self.name, &block) end
		def post(route, &block)    FrankStyle.make_camping_route('post', route, self.name, &block) end
		def delete(route, &block)  FrankStyle.make_camping_route('delete', route, self.name, &block) end
		def head(route, &block)    FrankStyle.make_camping_route('head', route, self.name, &block) end
		def options(route, &block) FrankStyle.make_camping_route('options', route, self.name, &block) end
		def patch(route, &block)   FrankStyle.make_camping_route('patch', route, self.name, &block) end
		def link(route, &block)    FrankStyle.make_camping_route('link', route, self.name, &block) end
		def unlink(route, &block)  FrankStyle.make_camping_route('unlink', route, self.name, &block) end
	end

	def self.included(mod)
		mod.extend(ClassMethods)
	end

	# required for compliance reasons
	def self.setup(app, *a, &block) end

end

def get(route, &block)     FrankStyle.make_camping_route('get', route, "Frank", &block) end
def put(route, &block)     FrankStyle.make_camping_route('put', route, "Frank", &block) end
def post(route, &block)    FrankStyle.make_camping_route('post', route, "Frank", &block) end
def delete(route, &block)  FrankStyle.make_camping_route('delete', route, "Frank", &block) end
def head(route, &block)    FrankStyle.make_camping_route('head', route, "Frank", &block) end
def options(route, &block) FrankStyle.make_camping_route('options', route, "Frank", &block) end
def patch(route, &block)   FrankStyle.make_camping_route('patch', route, "Frank", &block) end
def link(route, &block)    FrankStyle.make_camping_route('link', route, "Frank", &block) end
def unlink(route, &block)  FrankStyle.make_camping_route('unlink', route, "Frank", &block) end
