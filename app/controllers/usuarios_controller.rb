class UsuariosController < ApplicationController
	layout	:choose_layout
	
	before_filter :autorizar_acceso, :except => [:login, :send_login]
	before_filter :UsuariosLeer, :except => [:index, :new, :create, :edit, :update, :destroy, :update2, :login, :send_login, :cambiapass, :logout]
	before_filter :UsuariosModificar, :except => [:show, :list, :update2, :login, :send_login, :cambiapass, :logout]
	
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
		@titulo = 'Listar Usuario'
    @usuarios = Usuario.find(:all, :order => 'apellidos')
  end

  def show
		@titulo = 'Mostrar Usuario'
    @usuario = Usuario.find(params[:id])
  end

  def new
		@titulo = 'Nuevo Usuario'
    @usuario = Usuario.new
    @accvuelos = {'Ninguno'=>'non', "Vicepresidencia"=>'vic', 'Operaciones normal'=>'ope','Operaciones Supervisor'=>'ope2',
      'Administracion'=>'adm', 'Comercial'=>'com', 'Mantenimiento'=>'man', 'Seguridad'=>'seg', 'Tecnologia'=>'tec','Capacitacion'=>'cap'}
  end

  def create
    @usuario = Usuario.new(params[:usuario])

    if @usuario.save
      flash[:notice] = 'Usuario creado satisfactoriamente.'
      redirect_to :action => 'list'
    else
      @accvuelos = {'Ninguno'=>'non', "Vicepresidencia"=>'vic', 'Operaciones normal'=>'ope','Operaciones Supervisor'=>'ope2',
        'Administracion'=>'adm', 'Comercial'=>'com', 'Mantenimiento'=>'man', 'Seguridad'=>'seg', 'Tecnologia'=>'tec','Capacitacion'=>'cap'}
      render :action => 'new'
    end
  end

  def edit
		@titulo = 'Editar Usuario'
    @usuario = Usuario.find(params[:id])
    @accvuelos = {'Ninguno'=>'non', 'Vicepresidencia'=>'vic', 'Operaciones normal'=>'ope','Operaciones Supervisor'=>'ope2',
      'Administracion'=>'adm', 'Comercial'=>'com', 'Mantenimiento'=>'man', 'Seguridad'=>'seg', 'Tecnologia'=>'tec','Capacitacion'=>'cap'}
  end

  def update
    @usuario = Usuario.find(params[:id])
		
    if @usuario.update_attributes(params[:usuario])
      flash[:notice] = 'Usuario actualizado satisfactoriamente.'
      redirect_to :action => 'show', :id => @usuario
    else
      @accvuelos = {'Ninguno'=>'non', 'Vicepresidencia'=>'vic', 'Operaciones normal'=>'ope','Operaciones Supervisor'=>'ope2',
      'Administracion'=>'adm', 'Comercial'=>'com', 'Mantenimiento'=>'man', 'Seguridad'=>'seg', 'Tecnologia'=>'tec','Capacitacion'=>'cap'}

      render :action => 'edit'
    end
  end

  def update2
    @usuario = Usuario.find(params[:id])
    if @usuario.update_attributes(params[:usuario])
      flash[:notice] = 'Password cambiado satisfactoriamente.'
			session[:usuario]=nil
			redirect_to(:action => 'login')
    else
      render :action => 'cambiapass'
    end
  end

  def destroy
   	Usuario.find(params[:id]).destroy
   	redirect_to :action => 'list'
  end
  
  def login
		@titulo = 'Iniciar Sesion'
		@usuario = Usuario.new
	end

	def send_login
		@usuario = Usuario.new(params[:usuario])
		usuario_logeado = @usuario.try_to_login
		
		if usuario_logeado
			session[:usuario]=usuario_logeado
			flash[:notice]='Usuario logeado'
			redirect_to(:controller => 'principal', :action => 'bienvenida')
		else
			flash[:notice]='Usuario incorrecto'
			redirect_to(:action => 'login')
		end
	end

	def cambiapass
		@usuario = Usuario.find(session[:usuario].id)
	end

	def logout
		session[:usuario]=nil
		flash[:notice]='Sesion finalizada ...'
		redirect_to(:action => 'login')
	end

private #------------------------------------------

	def choose_layout

		if ['login'].include? action_name
			'login'
		else
			'usuarios'		
		end
	
	end

end
