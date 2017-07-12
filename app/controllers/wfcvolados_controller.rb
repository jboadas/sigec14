class WfcvoladosController < ApplicationController
	layout :choose_layout
	before_filter :autorizar_acceso

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update ],
		:redirect_to => { :action => :list }

	def list
		@equipos = Cabequipo.find :all
		@wfcvolados = Wfcvuelo.new
		@anios = (2010..2025)
		@meses = {"Enero" => 1, "Febrero" => 2, "Marzo"=> 3, "Abril"=> 4, "Mayo"=> 5, "Junio"=> 6, "Julio"=> 7, "Agosto"=> 8,
			"Septiembre"=> 9, "Octubre"=> 10, "Noviembre"=> 11, "Diciembre"=> 12}
    @meses = @meses.sort {|a,b| a[1]<=>b[1]}
		@dias = (1..31)
		@horas = (0..23)
		@minutos = (0..59)
		render :action => 'equipos'
	end

	def listfiltrada
    @wfcons = Wfcvuelo.new(params[:wfcvolado])
    @equipoid = @wfcons.cabequipo_id
		@intmesini = @wfcons.mesini
		@intanoini = @wfcons.anoini
		@intmesfin = @wfcons.mesfin
		@intanofin = @wfcons.anofin

		hoy = Time.now

		@wfcvolados = Wfcvuelo.find :all, :conditions=> [ 'cabequipo_id = ? and status <> 1001 and tipo = 0 and anoini >= ? and anofin <= ? and mesini >= ? and mesfin <= ? ', @equipoid, @intanoini, @intanofin, @intmesini, @intmesfin ], :order => 'anoini DESC,mesini DESC,diaini DESC,horaini DESC,minini DESC'
    @equipo = Cabequipo.find(@equipoid)
	end

	def show
		@wfcvolado = Wfcvuelo.find(params[:id])
	end

	def new
		@wfcvolado = Wfcvuelo.new
	end

	def create
		@wfcvuelo = Wfcvuelo.new(params[:wfcvolado])
		if @wfcvuelo.save
			flash[:notice] = 'Wfcvuelo was successfully created.'
			redirect_to :action => 'list'
		else
			render :action => 'new'
		end
	end

	def edit
		@wfcvolado = Wfcvuelo.find(params[:id])
	end

	def update
		@wfcvolado = Wfcvuelo.find(params[:id])
		if @wfcvolado.update_attributes(params[:wfcvolado])
			flash[:notice] = 'Wfcvolado was successfully updated.'
			redirect_to :action => 'show', :id => @wfcvolado
		else
			render :action => 'edit'
		end
	end

	private
	def choose_layout
		if [ 'list','show','listfiltrada'].include? action_name
			'volados'
		end
	end

end
