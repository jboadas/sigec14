class CabvuelosController < ApplicationController

	before_filter :autorizar_acceso

  def create
    @cabvuelo = Cabvuelo.new(params[:cabvuelo])
    @cabvuelo.conf01 = @cabvuelo.cabequipo.config1
    @cabvuelo.conf02 = @cabvuelo.cabequipo.config2
    @cabvuelo.conf03 = @cabvuelo.cabequipo.config3
    @cabvuelo.conf04 = @cabvuelo.cabequipo.config4
    @cabvuelo.conf05 = @cabvuelo.cabequipo.config5
    @cabvuelo.save
    render :xml => @cabvuelo.to_xml
  end

  def list
    @cabvuelos = Cabvuelo.find :all
    render :xml => @cabvuelos.to_xml
  end

  def listf
    @cabvuelos = Cabvuelo.find(:all, :conditions => ["cabequipo_id = ?",params[:id]])
    render :xml => @cabvuelos.to_xml
  end

  def update
    @cabvuelo = Cabvuelo.find(params[:id])
    @cabvuelo.update_attributes(params[:cabvuelo])
    render :xml => @cabvuelo.to_xml
  end

  def updateass
  	@cabvuelonew = Cabvuelo.new(params[:cabvuelo])
    @cabvuelo = Cabvuelo.find(params[:id])
    pos = @cabvuelonew.posicion
    ser = @cabvuelonew.serie
    if(ser==1)
  		cadena = @cabvuelo.conf01
  	end
    if(ser==2)
  		cadena = @cabvuelo.conf02
  	end
    if(ser==3)
  		cadena = @cabvuelo.conf03
  	end
    if(ser==4)
  		cadena = @cabvuelo.conf04
  	end
    if(ser==5)
  		cadena = @cabvuelo.conf05
  	end
		if(cadena[pos].chr=="C" or cadena[pos].chr=="D" or cadena[pos].chr=="E" or cadena[pos].chr=="F")
	    @cabvuelo.update_attributes(params[:cabvuelo])
		end
    render :xml => @cabvuelo.to_xml
  end

  def updateunass
  	@cabvuelonew = Cabvuelo.new(params[:cabvuelo])
    @cabvuelo = Cabvuelo.find(params[:id])
    pos = @cabvuelonew.posicion
    ser = @cabvuelonew.serie
    if(ser==1)
  		cadena = @cabvuelo.conf01
  	end
    if(ser==2)
  		cadena = @cabvuelo.conf02
  	end
    if(ser==3)
  		cadena = @cabvuelo.conf03
  	end
    if(ser==4)
  		cadena = @cabvuelo.conf04
  	end
    if(ser==5)
  		cadena = @cabvuelo.conf05
  	end
		if(cadena[pos].chr=="N" or cadena[pos].chr=="X" or cadena[pos].chr=="W" or cadena[pos].chr=="O")
	    @cabvuelo.update_attributes(params[:cabvuelo])
		end
    render :xml => @cabvuelo.to_xml
  end


  def delete
    @cabvuelo = Cabvuelo.find(params[:id])
    @cabvuelo.destroy
    render :xml => @cabvuelo.to_xml
  end


end
