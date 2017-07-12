class CabloginsController < ApplicationController

	before_filter :autorizar_acceso
	
  def create
    @cablogin = Cablogin.new(params[:cablogin])
    @cablogin.save
    render :xml => @cablogin.to_xml
  end

  def list
    @cablogins = Cablogin.find :all
    render :xml => @cablogins.to_xml
  end

  def update
    @cablogin = Cablogin.find(params[:id])
    @cablogin.update_attributes(params[:cablogin])
    render :xml => @cablogin.to_xml
  end

  def delete
    @cablogin = Cablogin.find(params[:id])
    @cablogin.destroy
    render :xml => @cablogin.to_xml
  end


end
