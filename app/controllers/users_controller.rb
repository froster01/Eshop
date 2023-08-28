class UsersController < ApplicationController
    require 'securerandom'
  
    # To create new user from input form
    def new
      @user = User.new
    end
  
    # Handle user creation account and save to the database
    def create
      @user = User.new(user_params)
      @user.verification_token = SecureRandom.hex(20) # Generate a unique verification token
    
      ActiveRecord::Base.transaction do
        if User.exists?(email: @user.email) && User.exists?(username: @user.username)
          flash.now[:danger] = "Account already registered with this email and username. Please log in or use different credentials."
          render :new
        elsif User.exists?(email: @user.email)
          flash.now[:danger] = "Email already registered. Please log in or use a different email."
          render :new
        elsif User.exists?(username: @user.username)
          flash.now[:danger] = "Username already taken. Please choose a different username."
          render :new
        elsif @user.save
          begin
            UserMailer.verification_email(@user).deliver_now
            redirect_to root_path, success: "Please check your email for a verification link."
          rescue StandardError => e
            flash.now[:warning] = "User created, but verification email couldn't be sent. Please contact support."
            raise e # Re-raise the exception to trigger the transaction rollback
          end
        else
          redirect_to new_user_path, danger: "Please key in all of the details"
        end
      end
    end
    
  
    # Edit user profile
    def edit
      @user = current_user
    end
  
    # Handle edit user account
    def update
      @user = current_user
      if @user.update(user_params)
        redirect_to root_path, success: "Account has been updated successfully!"
      else
        redirect_to edit_user_path, info: "Your account is not fully updated!"
      end
    end
  
    private
  
    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end
  end
  