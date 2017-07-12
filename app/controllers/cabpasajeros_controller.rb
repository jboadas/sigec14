class CabpasajerosController < ApplicationController

	before_filter :autorizar_acceso
  
  def create
    @cabpasajero = Cabpasajero.new(params[:cabpasajero])
    @cabpasajero.save
    render :xml => @cabpasajero.to_xml
  end

  def list
    @cabpasajeros = Cabpasajero.find :all
    render :xml => @cabpasajeros.to_xml
  end

  def listf
    @cabpasajeros = Cabpasajero.find(:all, :conditions => ["cabvuelo_id = ?",params[:id]])
    render :xml => @cabpasajeros.to_xml
  end


  def update
    @cabpasajero = Cabpasajero.find(params[:id])
    @cabpasajero.update_attributes(params[:cabpasajero])
    render :xml => @cabpasajero.to_xml
  end

  def updateassign
  	@cabpasajeronew = Cabpasajero.new(params[:cabpasajero])
    @cabpasajero = Cabpasajero.find(params[:id])
    @buscapas = Cabpasajero.find(:all, :conditions => {:puesto => @cabpasajeronew.puesto})
		if (@buscapas == [])
    	@cabpasajero.update_attributes(params[:cabpasajero])
    end
    render :xml => @cabpasajero.to_xml
  end

  def delete
    @cabpasajero = Cabpasajero.find(params[:id])
    @cabpasajero.destroy
    render :xml => @cabpasajero.to_xml
  end
  
end
