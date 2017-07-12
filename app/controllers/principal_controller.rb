class PrincipalController < ApplicationController
	layout	'principal'

	before_filter :autorizar_acceso

	def index
		render :action => 'bienvenida'
	end

end
