# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	def buscarLogin(id, usuarios)
		for usuario in usuarios
			if usuario.id == id
				return usuario.login
			end
		end
	end


#### Permisos para Leer

	def UsLe #Usuarios leer
		le('Usuarios Leer','Usuarios Modificar')
	end


#### Permisos para Modificar

	def UsMo #usuarios modificar
		mo('Usuarios Modificar')
	end

	def le(leer,modificar)
		if (acc(leer) || acc(modificar))
			return true
		else
			return false
		end
	end

	def mo(modificar)
		if acc(modificar)
			return true
		else
			return false
		end
	end

	def acc(amodulo)

		admin = session[:usuario].admin
    if(admin == "SI")
      return true;
    end
		return false
	end

# anexa ceros a a la fecha para formatearla
	def ancer(partefecha)
		strpartefecha = partefecha.to_s
		if(partefecha<10)
			strpartefecha = '0' + strpartefecha
		end
		return strpartefecha
	end
end
