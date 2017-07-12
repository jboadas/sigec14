class CabequiposController < ApplicationController

	before_filter :autorizar_acceso
	
  def create
    @cabequipo = Cabequipo.new(params[:cabequipo])
    @cabequipo.save
    render :xml => @cabequipo.to_xml
  end

  def list
    @cabequipos = Cabequipo.find :all
    render :xml => @cabequipos.to_xml
  end

  def update
    @cabequipo = Cabequipo.find(params[:id])
    @cabequipo.update_attributes(params[:cabequipo])
    render :xml => @cabequipo.to_xml
  end

  def delete
    @cabequipo = Cabequipo.find(params[:id])
    @cabequipo.destroy
    render :xml => @cabequipo.to_xml
  end



end
