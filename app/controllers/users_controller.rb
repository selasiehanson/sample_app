class UsersController < ApplicationController
	def create
		@user = User.create(params[:user])
		if @user.save
			flash[:success] = "Welcome to the sample App!"
			redirect_to @user
		else
			render "new"
		end	
	end

	def new
	  	@user = User.new
	end

	def show
	  	#@user = User.find(params[:id])
	  	@user = User.find(params[:id])
	end
end
