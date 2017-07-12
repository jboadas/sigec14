require "digest/sha1"
class Usuario < ActiveRecord::Base

	attr_accessor :password
	attr_accessible :nombres, :apellidos, :cedula, :login, :password, :email, :controlador, :admin
	
	validates_presence_of :login
	validates_uniqueness_of :login
	validates_length_of :login, :within => 1..40, :too_long => "Login demasiado largo", :too_short => "Login no puede estar en blanco"
	
	def before_create
		self.hashed_password = Usuario.hash_password(self.password)
	end
	
	def before_update
		if self.password != ""
			self.hashed_password = Usuario.hash_password(self.password)
		end		
	end
	
	def after_create
		@password = nil
	end

	def after_update
		@password = nil
	end
	
	def self.login(login, password)
		hashed_password = hash_password(password || "")
		self.find(:first, :conditions => ["login = ? AND hashed_password = ?", login, hashed_password])
	end

	def try_to_login
		Usuario.login(self.login, self.password)
	end
	
	private #-----------------------
	
	def self.hash_password(password)
		Digest::SHA1.hexdigest(password)
	end

end
