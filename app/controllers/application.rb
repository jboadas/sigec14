# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_sigec14_session_id'


  private #---------------------------------

	def UsuariosLeer
		leer('Usuarios Leer','Usuarios Modificar')
	end

	def UsuariosModificar
		modif('Usuarios Modificar')
	end

	
	def leer(leer,modificar)
		if (acceso(leer) || acceso(modificar))
			return true
		else
			redirect_to(:controller => 'principal', :action => 'bienvenida')
			return false
		end
	end
	
	def modif(modificar)
		if acceso(modificar)
			return true
		else
			redirect_to(:action => 'list')
			return false
		end
	end

  def modifVuelos(modificar)
		if acceso(modificar)
			return true
		else
			redirect_to(:controller => 'principal', :action => 'bienvenida')
			return false
		end
	end

	def acceso(amodulo)

		admin = session[:usuario].admin
    if admin == 'SI'
      return true
    end
		return false
	end
  
	def autorizar_acceso
		if not session[:usuario]
			flash[:notice]='No autorizado ...'
			redirect_to(:controller => 'usuarios', :action => 'login')
			return false
		end
	end
end

  def rescue_404
    rescue_action_in_public CustomNotFoundError.new
  end

  def rescue_action_in_public(exception)
    case exception
      when CustomNotFoundError, ::ActionController::UnknownAction then
        #render_with_layout "shared/error404", 404, "standard"
        #render :template => "shared/error404", :layout => "standard", :status => "404"
        redirect_to(:controller => 'usuarios', :action => 'login')
      else
        @message = exception
        #render :template => "shared/error", :layout => "standard", :status => "500"
        redirect_to(:controller => 'usuarios', :action => 'login')
    end
  end

  def local_request?
    return false
  end