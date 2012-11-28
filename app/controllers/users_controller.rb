class UsersController < ApplicationController
	before_filter :signed_in_user,  only: [:index, :edit, :update]
	before_filter :correct_user, only: [:edit, :update]
	before_filter :admin_user , only: :destroy


	def index
		@users = User.paginate(page: params[:page])
	end

	def create
		@user = User.create(params[:user])
		if @user.save
			sign_in @user
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
	  	@microposts = @user.microposts.paginate(page: params[:page])
	end

	def edit
		@user = User.find(params[:id])
	end

	def update
		@user = User.find(params[:id])
		if @user.update_attributes(params[:user])
			flash[:success] = "Profile Updated"
			sign_in @user
			redirect_to @user
		else
			render 'edit' 
		end
	end

	def destroy
		User.find(params[:id]).destroy
		flash[:success] = "User destroyed"
		redirect_to users_url
	end

	private
		def correct_user
			@user = User.find(params[:id])
			redirect_to(root_path) unless current_user?(@user)
		end

		def admin_user
			redirect_to(root_path) unless current_user.admin?
		end
end
