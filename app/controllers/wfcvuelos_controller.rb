require "pdf/writer"
require "pdf/simpletable"
class WfcvuelosController < ApplicationController

	layout :choose_layout
	#MARCA: cambiar filtros de acceso
	before_filter :autorizar_acceso

  #Calculo de los milisegundos entre 2 fechas para hacer profiling
  def time_diff_milli(start, finish)
    (finish - start) * 1000.0
  end

  def create
		@wfcvuelo = Wfcvuelo.new(params[:wfcvuelo])
		@wfcvuelo.save
		rta = @wfcvuelo.origen + '/' + @wfcvuelo.destino
		fecha = @wfcvuelo.diaini.to_s+'/'+@wfcvuelo.mesini.to_s+'/'+@wfcvuelo.anoini.to_s
		hora = @wfcvuelo.horaini.to_s+':'+@wfcvuelo.minini.to_s
		status = @wfcvuelo.status
		tipo = @wfcvuelo.tipo
		if tipo == 0
			message = '<b>Vuelo creado: </b></br>'
			message = message + "<b> Ruta: </b>"+ rta +'</br>'
		elsif tipo ==1
			message = '<b>Mantenimiento creado: </b></br>'
		else
			message = '<b>Entrenamiento creado: </b></br>'
		end
		message = message + '<b> Fecha: </b>'+ fecha +'</br>'
		message = message + '<b> Hora: </b>'+ hora +'</br>'
		@usuarios = Usuario.find :all
		#MARCA: aqui se envian los mensajes de correo para crear
		if session[:usuario]!=nil
			for usuario in @usuarios
				if usuario.controlador == 'ope' || usuario.controlador == 'seg' || usuario.controlador == 'man' || usuario.controlador == 'vic'
					if tipo == 0
						UserMailer.deliver_contact(usuario.email, 'Intranet: Creado nuevo vuelo (o,s,m,v)', message)
					else
						UserMailer.deliver_contact(usuario.email, 'Intranet: Creado nuevo Mantenimiento (o,s,m,v)', message)
					end
				end
			end
		else
			if tipo == 0
				UserMailer.deliver_contact('jesus.boadas@perlaairlines.com', 'Intranet: Creado nuevo vuelo (o,s,m,v)', message)
			else
				UserMailer.deliver_contact('jesus.boadas@perlaairlines.com', 'Intranet: Creado nuevo Mantenimiento (o,s,m,v)', message)
			end
		end
		#hasta aqui se comenta
		render :xml => @wfcvuelo.to_xml
	end

	def list
		@wfcvuelos = Wfcvuelo.find :all
		render :xml => @wfcvuelos.to_xml
	end


	def listEquipos
		@cabequipos = Cabequipo.find :all
		render :action => 'equipos'
	end


	def listVueloActual
		#se listan los vuelos de 2 meses atras
		hoy = Time.now - (60*24*60*60)

		wfcvuelos = Wfcvuelo.find(:all, :conditions => ["cabequipo_id = ?",params[:id]])
		@wfc = []

		for wfcvuelo in wfcvuelos
			if wfcvuelo.anoini > hoy.year
				@wfc << wfcvuelo
			end
			if wfcvuelo.anoini == hoy.year
				if wfcvuelo.mesini > hoy.month
					@wfc << wfcvuelo
				end
				if wfcvuelo.mesini == hoy.month
					if wfcvuelo.diaini >= hoy.day
						@wfc << wfcvuelo
					end
				end
			end
		end

		render :xml => @wfc.to_xml
	end

	def inicio
		hoy = Time.now
		#aqui le digo cuantos dias atrasados quiero ver en la tabla
		mes = Time.now - (60*24*60*60)
		if session[:usuario]!=nil
			usu = session[:usuario].login
			ger = session[:usuario].controlador
			#else
			#  usu = "pruebas"
			#  ger = "adm"
			#MARCA: cambio de usuario desarrollo
		end
		status = {"ano" => hoy.year, "mes" => hoy.month, "dia"=> hoy.day, "login"=>usu,"gerencia"=>ger,"aano" => mes.year, "ames" => mes.month, "adia"=> mes.day}
		#status = {"ano" => hoy.year, "mes" => hoy.month, "dia"=> hoy.day, "login"=>'jesus.boadas',"gerencia"=>'4'}
		render :xml => status.to_xml({:root => "status"})
	end

	def consultahoras
		@equipos = Cabequipo.find(:all)
		@wfcvolados = Wfcvuelo.new
		@anios = (2010..2025)
		@meses = {"Enero" => 1, "Febrero" => 2, "Marzo"=> 3, "Abril"=> 4, "Mayo"=> 5, "Junio"=> 6, "Julio"=> 7, "Agosto"=> 8,
			"Septiembre"=> 9, "Octubre"=> 10, "Noviembre"=> 11, "Diciembre"=> 12}
    @meses = @meses.sort {|a,b| a[1]<=>b[1]}
		@dias = (1..31)
		@horas = (0..23)
		@minutos = (0..59)
		@tripuls = Wfctripulante.find(:all)

	end

	def ciclosequipos
		@equipos = Cabequipo.find(:all)

	end

	def horasequipos
		@equipos = Cabequipo.find(:all)
		@wfcvolados = Wfcvuelo.new
		@anios = (2010..2025)
		@meses = {"Enero" => 1, "Febrero" => 2, "Marzo"=> 3, "Abril"=> 4, "Mayo"=> 5, "Junio"=> 6, "Julio"=> 7, "Agosto"=> 8,
			"Septiembre"=> 9, "Octubre"=> 10, "Noviembre"=> 11, "Diciembre"=> 12}
    @meses = @meses.sort {|a,b| a[1]<=>b[1]}
		@dias = (1..31)
		@horas = (0..23)
		@minutos = (0..59)
    #logger.info(@meses)
	end

	def detalleoper
		
    @wfcons = Wfcvuelo.new(params[:wfcvolado])

		@equipo = @wfcons.cabequipo_id
		@intdiaini = @wfcons.diaini
		@intmesini = @wfcons.mesini
		@intanoini = @wfcons.anoini
		@intdiafin = @wfcons.diafin
		@intmesfin = @wfcons.mesfin
		@intanofin = @wfcons.anofin

		#@equipo = params[:equipo]

		#@wfcvolados = Wfcvolado.find :all, :conditions=> {'cerrarvuelo' => '1', 'cabequipo_id' => @equipo}, :order => 'anoini,mesini,diaini,horaini,minini'
		@repopers = []

		#por cada vuelo verificar si la fecha esta en el intervalo y si se encuentra calcular las horas de cada tripulante

		@feiniint = DateTime.new(@intanoini,@intmesini,@intdiaini,0,0) #fecha de inicio del intervalo
		@fefinint = DateTime.new(@intanofin,@intmesfin,@intdiafin,0,0) #fecha de final del intervalo que se desea calcular

		@showfeini=@intdiaini.to_s+"/"+@intmesini.to_s+"/"+@intanoini.to_s
		@showfefin=@intdiafin.to_s+"/"+@intmesfin.to_s+"/"+@intanofin.to_s
		#busco todos los vuelos que esten cerrados
		if @equipo != nil
			@wfcvolados = Wfcvuelo.find :all, :conditions=> {'cerrarvuelo' => '1', 'cabequipo_id' => @equipo}
      @matequip = Cabequipo.find :first, :conditions=> {'id'=>@equipo}
			@matricula = @matequip.Matricula
    else
			@wfcvolados = Wfcvuelo.find :all, :conditions=> {'cerrarvuelo' => '1'}
		end

		@tothor = 0
		@totmin = 0

      for wfcvolado in @wfcvolados
          unless (wfcvolado.status == 1001)
            #horas de vuelo
            fechaini = DateTime.new(wfcvolado.anoini, wfcvolado.mesini, wfcvolado.diaini, wfcvolado.horaini, wfcvolado.minini)
            fechafin = DateTime.new(wfcvolado.anofin, wfcvolado.mesfin, wfcvolado.diafin, wfcvolado.horafin, wfcvolado.minfin)

            #horas bloque
            #fechaini = DateTime.new(wfcvolado.banoini, wfcvolado.bmesini, wfcvolado.bdiaini, wfcvolado.bhoraini, wfcvolado.bminini)
            #fechafin = DateTime.new(wfcvolado.banofin, wfcvolado.bmesfin, wfcvolado.bdiafin, wfcvolado.bhorafin, wfcvolado.bminfin)

            if ((fechaini >= @feiniint) && (fechafin <= @fefinint)) ||
              ((fechaini <= @feiniint) && (fechafin >= @feiniint) && (fechafin <= @fefinint )) ||
              ((fechaini <= @feiniint) && (fechafin >= @fefinint)) ||
              ((fechaini >= @feiniint) && (fechaini <= @fefinint) && (@fefinint >= fechafin))

              if ((fechaini >= @feiniint) && (fechafin <= @fefinint))
                diferencia = fechafin - fechaini
              end

              if ((fechaini <= @feiniint) && (fechafin >= @feiniint) && (fechafin <= @fefinint ))
                diferencia = fechafin - @feiniint
              end

              if ((fechaini <= @feiniint) && (fechafin >= @fefinint))
                diferencia = @fefinint - @feiniint
              end

              if ((fechaini >= @feiniint) && (fechaini <= @fefinint) && (fechafin >= @fefinint))
                diferencia = @fefinint - fechaini
              end

              hours,minutes,seconds,frac = Date.day_fraction_to_time(diferencia)

              @tothor = @tothor + hours
              @totmin = @totmin + minutes

              if (@totmin >= 60)
                @tothor = @tothor + (@totmin/60)
                @totmin = @totmin % 60
              end
              achor="0"
              acmin="0"
              if @tothor < 10
                achor="0"+@tothor.to_s
              else
                achor=@tothor.to_s
              end
              if @totmin < 10
                acmin="0"+@totmin.to_s
              else
                acmin=@totmin.to_s
              end
              acumulado=achor+":"+acmin
              mini="0"
              minf="0"
              if wfcvolado.minini < 10
                mini="0"+wfcvolado.minini.to_s
              else
                mini=wfcvolado.minini.to_s
              end
              if wfcvolado.minfin < 10
                minf="0"+wfcvolado.minfin.to_s
              else
                minf=wfcvolado.minfin.to_s
              end
              despegue = wfcvolado.diaini.to_s + '/' +  wfcvolado.mesini.to_s + '/' +  wfcvolado.anoini.to_s+'-'+ wfcvolado.horaini.to_s+':'+mini
              aterrizaje = wfcvolado.diafin.to_s + '/' +	wfcvolado.mesfin.to_s + '/' +  wfcvolado.anofin.to_s+'-'+ wfcvolado.horafin.to_s+':'+minf
              ruta = wfcvolado.origen+"/"+wfcvolado.destino
              tiempopierna=hours.to_s+":"+minutes.to_s
              @repopers << [wfcvolado.logbook,ruta,despegue,aterrizaje,tiempopierna,acumulado]
            end
        end
      end

  end


	def detallemant
		@wfcons = Wfcvuelo.new(params[:wfcvolado])
		@equipo = @wfcons.cabequipo_id
		@wfcvolados = Wfcvuelo.find :all, :conditions=> {'cerrarvuelo' => '1', 'cabequipo_id' => @equipo}, :order => 'anoini,mesini,diaini,horaini,minini'
		@repmants = []
		ciclos = 40120
		totaltime = 66833.8
		actt = totaltime
		actc = ciclos
		for wfcvolado in @wfcvolados
			fechaini = DateTime.new(wfcvolado.anoini, wfcvolado.mesini, wfcvolado.diaini, wfcvolado.horaini, wfcvolado.minini)
			fechafin = DateTime.new(wfcvolado.anofin, wfcvolado.mesfin, wfcvolado.diafin, wfcvolado.horafin, wfcvolado.minfin)
			fec = wfcvolado.diaini.to_s + '/' +  wfcvolado.mesini.to_s + '/' +  wfcvolado.anoini.to_s
			mini="0"
			minf="0"
			if wfcvolado.minini < 10
				mini="0"+wfcvolado.minini.to_s
			else
				mini=wfcvolado.minini.to_s
			end
			if wfcvolado.minfin < 10
				minf="0"+wfcvolado.minfin.to_s
			else
				minf=wfcvolado.minfin.to_s
			end
			despegue = wfcvolado.diaini.to_s + '/' +	wfcvolado.mesini.to_s + '/' +  wfcvolado.anoini.to_s+'-'+ wfcvolado.horaini.to_s+':'+mini
			aterrizaje = wfcvolado.diafin.to_s + '/' +  wfcvolado.mesfin.to_s + '/' +  wfcvolado.anofin.to_s+'-'+ wfcvolado.horafin.to_s+':'+minf
			rut = wfcvolado.origen + '/' + wfcvolado.destino
			diferencia = fechafin - fechaini
			hours,minutes,seconds,frac = Date.day_fraction_to_time(diferencia)
			fr = minutes/6
			if (fr <=1)
				min = 1
			end
			if (fr >1 && fr <=2)
				min = 2
			end
			if (fr >2 && fr <=3)
				min = 3
			end
			if (fr >3 && fr <=4)
				min = 4
			end
			if (fr >4 && fr <=5)
				min = 5
			end
			if (fr >5 && fr <=6)
				min = 6
			end
			if (fr >6 && fr <=7)
				min = 7
			end
			if (fr >7 && fr <=8)
				min = 8
			end
			if (fr >8 && fr <=9)
				min = 9
			end
			if (fr >9)
				min = 10
			end
			acfh = hours.to_s+','+min.to_s
			actt = actt + hours + (min/10.0)
			actc = actc + 1 # ciclos
			@repmants << [fec, rut,acfh,actt,actc.to_s,despegue,aterrizaje]
		end
	end

	def calcularhoras

#    t1 = Time.now

    #logger.info("************************************** aqui empieza")
		@wfcons = Wfcvuelo.new(params[:wfcvolado])
    @errores = []
    @pilotos = []
    @tripulantes = []
    @despachadores = []
    @mecanicos = []
		@equipo = @wfcons.cabequipo_id
		@intdiaini = @wfcons.diaini
		@intmesini = @wfcons.mesini
		@intanoini = @wfcons.anoini
		@intdiafin = @wfcons.diafin
		@intmesfin = @wfcons.mesfin
		@intanofin = @wfcons.anofin
		tripul = @wfcons.log

		#por cada vuelo verificar si la fecha esta en el intervalo y si se encuentra calcular las horas de cada tripulante

		if(Date.valid_date?(@intanoini,@intmesini,@intdiaini) and Date.valid_date?(@intanofin,@intmesfin,@intdiafin))
      @feiniint = DateTime.new(@intanoini,@intmesini,@intdiaini,0,0) #fecha de inicio del intervalo
      @fefinint = DateTime.new(@intanofin,@intmesfin,@intdiafin,23,59) #fecha de final del intervalo que se desea calcular
    else
      @errorfecha = true
      @equipos = Cabequipo.find(:all)
      @wfcvolados = Wfcvuelo.new
      @anios = (2010..2025)
      @meses = {"Enero" => 1, "Febrero" => 2, "Marzo"=> 3, "Abril"=> 4, "Mayo"=> 5, "Junio"=> 6, "Julio"=> 7, "Agosto"=> 8,
                "Septiembre"=> 9, "Octubre"=> 10, "Noviembre"=> 11, "Diciembre"=> 12}
      @meses = @meses.sort {|a,b| a[1]<=>b[1]}
      @dias = (1..31)
      @horas = (0..23)
      @minutos = (0..59)
      @tripuls = Wfctripulante.find(:all)
      render :action => 'consultahoras'
      return
    end

		#@wfcvolados = Wfcvolado.find :all, :conditions=> {'cabequipo_id' => @wfcvolado.cabequipo_id  ,'cerrarvuelo' => '0'}
		#busco todos los vuelos que esten cerrados
		if @equipo != nil
			#@wfcvolados = Wfcvuelo.find :all, :conditions=> {'cerrarvuelo' => '1', 'cabequipo_id' => @equipo}
			@wfcvolados = Wfcvuelo.find_by_sql ["SELECT * FROM wfcvuelos WHERE cerrarvuelo = 1 AND cabequipo_id = ? AND anoini >= ? AND anofin <= ? AND status != 1001", @equipo, @intanoini, @intanofin]
			@matequip = Cabequipo.find :first, :conditions=> {'id'=>@equipo}
			@matricula = @matequip.Matricula
		else
			#@wfcvolados = Wfcvuelo.find :all, :conditions=> {'cerrarvuelo' => '1'}
			@wfcvolados = Wfcvuelo.find_by_sql ["SELECT * FROM wfcvuelos WHERE cerrarvuelo = 1 AND anoini >= ? AND anofin <= ? AND status != 1001", @intanoini, @intanofin]
		end

		@wfctripulantes = Wfctripulante.find(:all, :conditions =>["nombres not like '%ninguno%' and cedula not like '%000%' and (nombres like ? or apellidos like ?)",'%'+tripul+'%','%'+tripul+'%'], :order => 'orden,nombres')

		for wfctripulante in @wfctripulantes
			wfctripulante.horas = 0
			wfctripulante.minutos = 0
		end

		@tothor = 0
		@totmin = 0

    #calculo de tiempo
#    t2 = Time.now
#    msecs = time_diff_milli t1, t2
#    logger.info "tiempo epoch 001"
#    logger.info msecs
#    logger.info @wfcvolados.length
#    t1 = t2

		for wfcvolado in @wfcvolados

			if(Date.valid_date?(wfcvolado.banoini, wfcvolado.bmesini, wfcvolado.bdiaini) and Date.valid_date?(wfcvolado.banofin, wfcvolado.bmesfin, wfcvolado.bdiafin))
				fechaini = DateTime.new(wfcvolado.banoini, wfcvolado.bmesini, wfcvolado.bdiaini, wfcvolado.bhoraini, wfcvolado.bminini)
				fechafin = DateTime.new(wfcvolado.banofin, wfcvolado.bmesfin, wfcvolado.bdiafin, wfcvolado.bhorafin, wfcvolado.bminfin)

				if ((fechaini >= @feiniint) && (fechafin <= @fefinint)) ||
					((fechaini <= @feiniint) && (fechafin >= @feiniint) && (fechafin <= @fefinint )) ||
					((fechaini <= @feiniint) && (fechafin >= @fefinint)) ||
					((fechaini >= @feiniint) && (fechaini <= @fefinint) && (@fefinint >= fechafin))

					if ((fechaini >= @feiniint) && (fechafin <= @fefinint))
						diferencia = fechafin - fechaini
					end

					if ((fechaini <= @feiniint) && (fechafin >= @feiniint) && (fechafin <= @fefinint ))
						diferencia = fechafin - @feiniint
					end

					if ((fechaini <= @feiniint) && (fechafin >= @fefinint))
						diferencia = @fefinint - @feiniint
					end

					if ((fechaini >= @feiniint) && (fechaini <= @fefinint) && (fechafin >= @fefinint))
						diferencia = @fefinint - fechaini
					end

					hours,minutes,seconds,frac = Date.day_fraction_to_time(diferencia)

					@tothor = @tothor + hours
					@totmin = @totmin + minutes

					for wfctripulante in @wfctripulantes
						if (wfctripulante.id == wfcvolado.capitan )
							wfctripulante.horas = wfctripulante.horas + hours
							wfctripulante.minutos = wfctripulante.minutos + minutes
						end
						if (wfctripulante.id == wfcvolado.copiloto)
							wfctripulante.horas = wfctripulante.horas + hours
							wfctripulante.minutos = wfctripulante.minutos + minutes
						end
						if (wfctripulante.id == wfcvolado.jefecab)
							wfctripulante.horas = wfctripulante.horas + hours
							wfctripulante.minutos = wfctripulante.minutos + minutes
						end
						if (wfctripulante.id == wfcvolado.trip01)
							wfctripulante.horas = wfctripulante.horas + hours
							wfctripulante.minutos = wfctripulante.minutos + minutes
						end
						if (wfctripulante.id == wfcvolado.trip02)
							wfctripulante.horas = wfctripulante.horas + hours
							wfctripulante.minutos = wfctripulante.minutos + minutes
						end
						if (wfctripulante.id == wfcvolado.trip03)
							wfctripulante.horas = wfctripulante.horas + hours
							wfctripulante.minutos = wfctripulante.minutos + minutes
						end
						if (wfctripulante.id == wfcvolado.trip04)
							wfctripulante.horas = wfctripulante.horas + hours
							wfctripulante.minutos = wfctripulante.minutos + minutes
						end
						if (wfctripulante.id == wfcvolado.desp)
							wfctripulante.horas = wfctripulante.horas + hours
							wfctripulante.minutos = wfctripulante.minutos + minutes
						end
						if (wfctripulante.id == wfcvolado.mec)
							wfctripulante.horas = wfctripulante.horas + hours
							wfctripulante.minutos = wfctripulante.minutos + minutes
						end
						if(wfctripulante.minutos >= 60)
							wfctripulante.horas = wfctripulante.horas + wfctripulante.minutos / 60 #division entera
							wfctripulante.minutos = wfctripulante.minutos % 60 # operacion mod
						end
						#wfctripulante.save
					end
					if (@totmin >= 60)
						@tothor = @tothor + (@totmin/60)
						@totmin = @totmin % 60
					end
					#retorno = {"Horas" => hours, "Minutos" => minutes}
				end
      else
         @errores << wfcvolado
      end
		end

    for wfctri in @wfctripulantes
      if wfctri.tipo == 'pil'
        @pilotos << wfctri
      end
      if wfctri.tipo == 'tri'
        @tripulantes << wfctri
      end
      if wfctri.tipo == 'des'
        @despachadores << wfctri
      end
      if wfctri.tipo == 'mec'
        @mecanicos << wfctri
      end
    end
		#render :xml => @wfctripulantes.to_xml
#    t2 = Time.now
#    msecs = time_diff_milli t1, t2
#    logger.info "tiempo epoch"
#    logger.info msecs
#    logger.info("************************************** aqui termina")
	end

	#MARCA: calculo de horas diurnas y nocturnas
#	def diurnoct(fini,ffin)
#
#		diur = 0
#		noct = 0
#		while(true)
#			if((5 <= fini.hour) && (fini.hour < 19))
#				nocturnal = DateTime.new(fini.year,fini.month,fini.day,19,0)
#				if(ffin < nocturnal)
#					diur = diur + (ffin-fini)
#					break
#				else
#					diur = diur + (nocturnal-fini)
#					fini = nocturnal
#				end
#			else
#				diurnal = DateTime.new(fini.year,fini.month,fini.day,5,0).next
#				if(ffin < diurnal)
#					noct = noct + (ffin-fini)
#					break
#				else
#					noct = noct + (diurnal-fini)
#					fini = diurnal
#				end
#			end
#		end
#		return diur,noct
#	end


	#esta clase se usa para hacer un array de hash que es enviado a la vista para asi poder calcular las horas
	class Datosvol
		attr_accessor :logbook, :origen, :destino, :banoini, :bmesini, :bdiaini, :bhoraini, :bminini, :banofin, :bmesfin,
			:bdiafin, :bhorafin, :bminfin, :total

		def initialize(logbook, origen, destino, banoini, bmesini, bdiaini, bhoraini, bminini, banofin, bmesfin, bdiafin,
					   bhorafin, bminfin, total)
			@logbook = logbook
			@origen = origen
			@destino = destino
			@banoini = banoini
			@bmesini = bmesini
			@bdiaini = bdiaini
			@bhoraini =bhoraini
			@bminini = bminini
			@banofin = banofin
			@bmesfin = bmesfin
			@bdiafin = bdiafin
			@bhorafin = bhorafin
			@bminfin = bminfin
			@total = total
		end
	end

	#calcula la diferencia entre 2 fechas
	def tiempointerv(ai,mei,di,hi,mii,af,mef,df,hf,mif)
		fechaini = DateTime.new(ai,mei,di,hi,mii) #fecha de inicio
		fechafin = DateTime.new(af,mef,df,hf,mif) #fecha de final
		diferencia = fechafin - fechaini
		hours,minutes,seconds,frac = Date.day_fraction_to_time(diferencia)
		if hours < 10
			horas = '0' + hours.to_s
		else
			horas = hours.to_s
		end
		if minutes < 10
			minutos = '0' + minutes.to_s
		else
			minutos = minutes.to_s
		end
		tiempo = horas + ':' + minutos
		return tiempo

	end

	def detalle

		@wfcvolados = []
		feiniint = DateTime.new(params[:anoini].to_i,params[:mesini].to_i,params[:diaini].to_i,0,0)
		fefinint = DateTime.new(params[:anofin].to_i,params[:mesfin].to_i,params[:diafin].to_i,0,0)
		@wfctripul = Wfctripulante.find(:first, :conditions => {'id' => params[:id]})
		wfcvols = Wfcvuelo.find(:all, :conditions => ['(capitan=? or copiloto=? or jefecab=? or trip01=? or trip02=? or trip03=?  or trip04=? or desp=? or mec=?) and (stfinvuelo=1) and (cerrarvuelo=1) and (status<>1001)',
												params[:id],params[:id],params[:id],params[:id],params[:id],params[:id],params[:id],params[:id],params[:id]], :order => 'anoini,mesini,diaini,horaini,minini')

		for wfcvol in wfcvols
			begin
        feini = DateTime.new(wfcvol.banoini,wfcvol.bmesini,wfcvol.bdiaini,0,0)
        fefin = DateTime.new(wfcvol.banofin,wfcvol.bmesfin,wfcvol.bdiafin,0,0)
        if(((feini>=feiniint) && (feini<=fefinint)) || ((fefin>=feiniint) && (fefin<=fefinint)))
          #aqui se usa el hash de arrays
          tiempo = tiempointerv(wfcvol.banoini, wfcvol.bmesini, wfcvol.bdiaini, wfcvol.bhoraini, wfcvol.bminini,
                      wfcvol.banofin, wfcvol.bmesfin, wfcvol.bdiafin, wfcvol.bhorafin, wfcvol.bminfin)
          @wfcvolados << Datosvol.new(wfcvol.logbook, wfcvol.origen, wfcvol.destino,
                        wfcvol.banoini, wfcvol.bmesini, wfcvol.bdiaini, wfcvol.bhoraini, wfcvol.bminini,
                        wfcvol.banofin, wfcvol.bmesfin, wfcvol.bdiafin, wfcvol.bhorafin, wfcvol.bminfin, tiempo)
        end
      rescue ArgumentError
        logger.info("Error de fecha")
        logger.info(wfcvol.id)
      end
		end

	end

	def historicoVuelos
		#60 dias X 24 horas X 60 mins X 60 segs
		hoy = Time.now

		wfcvuelos = Wfcvuelo.find :all, :conditions=> [ 'cabequipo_id = ?  and cerrarvuelo = 0 and status <> 1001 and tipo = 0', params[:id] ], :order => 'anoini,mesini,diaini,horaini,minini'
		@wfcvolados = []

		for wfcvuelo in wfcvuelos
			if wfcvuelo.anoini < hoy.year
				@wfcvolados << wfcvuelo
			end
			if wfcvuelo.anoini == hoy.year
				if wfcvuelo.mesini < hoy.month
					@wfcvolados << wfcvuelo
				end
				if wfcvuelo.mesini == hoy.month
					if wfcvuelo.diaini <= hoy.day
						@wfcvolados << wfcvuelo
					end
				end
			end
		end

		render :action => 'historico'
	end

	def confirmar
		@equipos = Cabequipo.find(:all)
		@titulo = 'Confirmar Vuelo'
		@status = {"Pendiente" => 0, "Efectuado" => 1, "No Efectuado"=> 2}
		@combus = {"Lts" => 0, "USG" => 1, "IMG"=> 2}
		@anios = (2010..2025)
		@meses = {"Enero" => 1, "Febrero" => 2, "Marzo"=> 3, "Abril"=> 4, "Mayo"=> 5, "Junio"=> 6, "Julio"=> 7, "Agosto"=> 8,
			"Septiembre"=> 9, "Octubre"=> 10, "Noviembre"=> 11, "Diciembre"=> 12}
		@dias = (1..31)
		@horas = (0..23)
		@minutos = (0..59)
		@caps = Wfctripulante.find(:all, :conditions => {"tipo" => 'pil', "activo" => 'si'})
		@tris = Wfctripulante.find(:all, :conditions => {"tipo" => 'tri', "activo" => 'si'})
		@desps = Wfctripulante.find(:all, :conditions => {"tipo" => 'des', "activo" => 'si'})
		@mecs = Wfctripulante.find(:all, :conditions => {"tipo" => 'mec', "activo" => 'si'})
		@wfcvolado = Wfcvuelo.find(params[:id])
		if @wfcvolado.banoini == 0
			@wfcvolado.banoini = @wfcvolado.anoini
		end
		if @wfcvolado.bmesini == 0
			@wfcvolado.bmesini = @wfcvolado.mesini
		end
		if @wfcvolado.bdiaini == 0
			@wfcvolado.bdiaini = @wfcvolado.diaini
		end
		if @wfcvolado.bhoraini == 0
			@wfcvolado.bhoraini = @wfcvolado.horaini
		end
		if @wfcvolado.bminini == 0
			@wfcvolado.bminini = @wfcvolado.minini
		end
		if @wfcvolado.banofin == 0
			@wfcvolado.banofin = @wfcvolado.anofin
		end
		if @wfcvolado.bmesfin == 0
			@wfcvolado.bmesfin = @wfcvolado.mesfin
		end
		if @wfcvolado.bdiafin == 0
			@wfcvolado.bdiafin = @wfcvolado.diafin
		end
		if @wfcvolado.bhorafin == 0
			@wfcvolado.bhorafin = @wfcvolado.horafin
		end
		if @wfcvolado.bminfin == 0
			@wfcvolado.bminfin = @wfcvolado.minfin
		end


	end


	def confirmarupdate
		@wfcvolado = Wfcvuelo.find(params[:id])
		wfcvolado = params[:wfcvolado]

		if wfcvolado[:stfinvuelo] != "0"
			wfcvolado[:cerrarvuelo]=1
		end

		if wfcvolado[:stfinvuelo] == "2"
			wfcvolado[:status]=1001
		end

		@wfcvolado.update_attributes(wfcvolado)
		@wfcvolados = Wfcvuelo.find :all, :conditions=> [ 'cabequipo_id = ?  and cerrarvuelo = 0 and status <> 1001 and tipo = 0', params[:id] ], :order => 'anoini,mesini,diaini,horaini,minini'
		#render :action => 'historico'
    redirect_to :controller => 'wfcvolados', :action => 'show', :id => @wfcvolado
	end


	def update
		@wfcvuelo = Wfcvuelo.find(params[:id])
		stini = @wfcvuelo.status
		fechaant = @wfcvuelo.diaini.to_s+'/'+@wfcvuelo.mesini.to_s+'/'+@wfcvuelo.anoini.to_s
		horaant = @wfcvuelo.horaini.to_s+':'+@wfcvuelo.minini.to_s
		fechafant = @wfcvuelo.diafin.to_s+'/'+@wfcvuelo.mesfin.to_s+'/'+@wfcvuelo.anofin.to_s
		horafant = @wfcvuelo.horafin.to_s+':'+@wfcvuelo.minfin.to_s
		wfcvuelot = params[:wfcvuelo]
		@wfcvuelo.update_attributes(wfcvuelot)
		rta = @wfcvuelo.origen + '/' + @wfcvuelo.destino
		operador = @wfcvuelo.operador
		fecha = @wfcvuelo.diaini.to_s+'/'+@wfcvuelo.mesini.to_s+'/'+@wfcvuelo.anoini.to_s
		hora = @wfcvuelo.horaini.to_s+':'+@wfcvuelo.minini.to_s
		fechaf = @wfcvuelo.diafin.to_s+'/'+@wfcvuelo.mesfin.to_s+'/'+@wfcvuelo.anofin.to_s
		horaf = @wfcvuelo.horafin.to_s+':'+@wfcvuelo.minfin.to_s

		status = @wfcvuelo.status
		tipo = @wfcvuelo.tipo
		difst = 0
		difst = stini - status
		if tipo == 0
			message = '<b>El vuelo ha sido modificado: </b></br>'
			message = message + " <b>Ruta: </b>"+ rta +'</br>'
			message = message + ' <b>Operador: </b>'+ operador +'</br>'
		else
			message = '<b>El Mantenimiento ha sido modificado: </b></br>'
		end
		message = message + ' <b>Fecha: </b>'+ fecha +'</br>'
		message = message + ' <b>Hora: </b>'+ hora +'</br>'
		cambiofec = false
		if(fechaant!= fecha || horaant != hora || fechafant != fechaf || horafant != horaf)
			cambiofec = true
			message = message + ' <b>Fecha Inicio Anterior: </b>'+ fechaant + '-' + horaant +'</br>'
			message = message + ' <b>Fecha Final Anterior: </b>'+ fechafant + '-' + horafant +'</br>'
			message = message + ' <b>Fecha Inicio Actual: </b>'+ fecha + '-' + hora +'</br>'
			message = message + ' <b>Fecha Final Actual: </b>'+ fechaf + '-' + horaf
		end
		@usuarios = Usuario.find :all
		#MARCA: aqui se envian los mensajes de correo de actualizar
		if cambiofec
			if tipo == 0
				UserMailer.deliver_contact('jesus.boadas@perlaairlines.com', 'Intranet: Vuelo Cambio de Fecha', message)
			else
				UserMailer.deliver_contact('jesus.boadas@perlaairlines.com', 'Intranet: Mantenimiento Cambio de Fecha', message)
			end
		end
		#desde aqui se comenta
		if session[:usuario]!=nil
			for usuario in @usuarios
				if usuario.controlador != 'non' && difst != 0
					if cambiofec
						if tipo == 0
							UserMailer.deliver_contact(usuario.email, 'Intranet: Vuelo Cambio de Fecha', message)
						else
							UserMailer.deliver_contact(usuario.email, 'Intranet: Mantenimiento Cambio de Fecha', message)
						end
					end
					if status == 10
						if usuario.controlador == 'ope' || usuario.controlador == 'man' || usuario.controlador == 'seg' || usuario.controlador == 'vic'
							UserMailer.deliver_contact(usuario.email, 'Intranet: Vuelo reactivado (o,m,s,v)', message)
						end
					end
					if status == 15
						if usuario.controlador == 'ope2' || usuario.controlador == 'vic' || usuario.controlador == 'seg'
							UserMailer.deliver_contact(usuario.email, 'Intranet: Vuelo cancelado (v)', message)
						end
					end
					if status == 17
						if usuario.controlador == 'ope2' || usuario.controlador == 'vic' || usuario.controlador == 'seg'
							UserMailer.deliver_contact(usuario.email, 'Intranet: Vuelo cancelado (v)', message)
						end
					end
					if status == 20
						if usuario.controlador == 'adm'
							UserMailer.deliver_contact(usuario.email, 'Intranet: Solicitud de cotizacion - Esperando por Administracion', message)
						end
					end
					if status == 30
						if usuario.controlador == 'com'
							UserMailer.deliver_contact(usuario.email, 'Intranet: Aceptacion de vuelo - Esperando por Comercial', message)
						end
					end
					if status == 40
						if usuario.controlador == 'adm'
							UserMailer.deliver_contact(usuario.email, 'Intranet: Firma de contrato - Esperando por Administracion', message)
						end
					end
					if status == 50
						if usuario.controlador == 'ope' || usuario.controlador == 'man' || usuario.controlador == 'seg' || usuario.controlador == 'adm' || usuario.controlador == 'vic'
							UserMailer.deliver_contact(usuario.email, 'Intranet: Inicio fase preparacion de vuelo (omsv)', message)
						end
					end
					if status == 100
						if usuario.controlador == 'ope2'
							UserMailer.deliver_contact(usuario.email, 'Intranet: Esperando autorizacion final (o2)', message)
						end
					end
					if status == 110
						if usuario.controlador == 'vic'
							UserMailer.deliver_contact(usuario.email, 'Intranet: Vuelo en GO (v)', message)
						end
					end
					if status == 1001
						UserMailer.deliver_contact(usuario.email, 'Intranet: Vuelo Eliminado', message)
					end
				end
			end
		end
		#hasta aqui se comenta
		render :xml => @wfcvuelo.to_xml
	end

	def delete
		@wfcvuelo = Wfcvuelo.find(params[:id])
		@wfcvuelo.destroy
		render :xml => @Wfcvuelo.to_xml
	end

	def listTripulacion
		#@wfctripulante = Wfctripulante.find :all
    @wfctripulante = Wfctripulante.find(:all, :conditions => {"activo" => 'si'}, :order => 'nombres')
		render :xml => @wfctripulante.to_xml
	end

	def genpdf

		@wfctripulantes = Wfctripulante.find(:all, :conditions =>["nombres not like ? and cedula not like ? and tipo not like ? and tipo not like ?",'%ninguno%','%000%','%mec%','%des%'], :order => 'orden,nombres')

		_pdf = PDF::Writer.new(:orientation => :landscape)
		_pdf.select_font "Times-Roman"
		table_data = []

		@wfctripulantes.each do |wfctripulante|
			if wfctripulante.horas < 10
				horas = '0'+ wfctripulante.horas.to_s
			else
				horas = wfctripulante.horas.to_s
			end

			if wfctripulante.minutos < 10
				minutos = '0'+ wfctripulante.minutos.to_s
			else
				minutos = wfctripulante.minutos.to_s
			end

			if(wfctripulante.horas+wfctripulante.minutos>0)
				table_data << {"Tripulante"=>wfctripulante.nombres+' '+wfctripulante.apellidos,
				   "Licencia"=> wfctripulante.cedula,
				   "Horas"=> horas + ':' + minutos,
				}
			end

		end
		table = PDF::SimpleTable.new
		table.data = table_data
		table.column_order = [ "Tripulante", "Licencia", "Horas"]
		table.title = "Informe Tiempo de Vuelo"
		table.render_on(_pdf)
		send_data _pdf.render, :filename => "vuelo.pdf",:type => "application/pdf"
	end


	private
	def choose_layout
		if [ 'historicoVuelos','confirmar','listEquipos','confirmarupdate','consultahoras','calcularhoras','detalle','detallemant','ciclosequipos','horasequipos','detalleoper'].include? action_name
			'vuelos'
		end
	end

end
