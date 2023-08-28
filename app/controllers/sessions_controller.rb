class SessionsController < ApplicationController
    # Handle user login
    def create
      user = User.find_by(username: params[:username])
  
      if user.nil?
        flash[:danger] = 'Invalid username or password.'
        render :new
      elsif user.verified?
        handle_verified_user(user)
      else
        handle_unverified_user
      end
    end
  
    # Handle email verification
    def verify_email
      user = User.find_by(username: params[:username])
      email = User.find_by(email: params[:email])
  
      if user.nil?
        flash[:danger] = 'User not found. Please sign up.'
      elsif user.verification_token == params[:token] && !user.verification_token_expired?
            user.update_columns(verified: 1)
            flash[:success] = 'Email verified! You can now log in.'
      else
        if email.exists?(email: params[:email])
          flash[:danger] = 'Email already registered. Please log in or use a different email.'
        else
          resend_verification_email(user)
          flash[:danger] = 'The link has expired. Please verify your email using the new link that has been sent.'
        end
      end
    
      session.delete(:username)
      redirect_to new_session_path
    rescue StandardError => e
      Rails.logger.error("Error while verifying email: #{e.message}\n#{e.backtrace.join("\n")}")
      flash[:danger] = 'An error occurred while verifying your email.'
      session.delete(:username)
      redirect_to new_session_path
    end
  
    # Handle user logout
    def destroy
      session[:user_id] = nil
      flash[:primary] = 'Logged out.'
      redirect_to root_path
    end
  
    private
  
    # Handle the case where the user is verified
    def handle_verified_user(user)
      if user.authenticate(params[:password])
        session[:user_id] = user.id
        flash[:success] = 'Logged in successfully!'
        redirect_to root_path
      else
        flash[:danger] = 'Invalid username or password.'
        render :new
      end
    end
  
    # Handle the case where the user is unverified
    def handle_unverified_user
      flash[:info] = 'Email not verified. Please check your email for the verification link.'
      render :new
    end
  
    # Resend verification email
    def resend_verification_email(user)
      user&.generate_verification_token
      UserMailer.verification_email(user).deliver_now
    end
  end
  
  