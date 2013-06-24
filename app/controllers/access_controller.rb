class AccessController < ApplicationController
  before_filter :confirm_logged_in,
    :except => [:login, :attempt_login, :logout, :forgot_password, :send_password_reset, :reset_password, :save_password]
 
  # def edit
  #   @request = Request.find(params[:id])
  # end

  # def delete
  #   @request = Request.find(params[:id])
  #   #pass some info about project into a partial which will be loaded via jQuery
  #   render(:partial => 'common/confirmation' )
  # end

  # def destroy
  #   Request.find(params[:id]).destroy
  #   @requests = Request.all
  #   redirect_to(:controller => 'requests', :action => 'index')
  # end

  def login
    #login form    
  end

  def attempt_login
    authorized_user = User.authenticate(params[:username], params[:password])
    if authorized_user
      #mark user as logged in
      session[:user_id] = authorized_user.id
      session[:username] = authorized_user.username
      session[:fullname] = authorized_user.first_name + ' ' + authorized_user.last_name
      session[:email] = authorized_user.email
      session[:phone] = authorized_user.phone
      # flash[:notice] = "You are now logged in."
      # expire_page :controller => 'requests', :action => 'list'
      redirect_to(:controller => 'requests', :action => 'index')
    else
      redirect_to(:action => 'login')
      flash[:error] = "Your username or password are incorrect"
    end
  end

  def logout
    #mark user as logged out
    session[:user_id] = nil
    session[:username] = nil
    # flash[:notice] = "You are now logged out."
    # expire_page :controller => 'requests', :action => 'list'
    redirect_to(:controller => 'access', :action => 'login')
  end

  def forgot_password
    
  end

  def send_password_reset
    token = User.create_reset_code
    email = params['email']
    @user = User.find_by_email(email)
    #CHANGE THIS SUBFOLDER to whatever you're going to name the app:
    @url = "#{request.host_with_port}/birch"
    if @user.nil?
      redirect_to(:action => 'forgot_password')
      flash[:error] = "There was no user found with that email address."
    else
      @user.reactivation_code = token
      @user.save!
      PasswordMailer.send_reset(@user, @url).deliver
      logger.info "Sent email to address: #{email}"
      redirect_to(:action => 'login')
      flash[:alert] = "You should receive an email to assist in resetting your password shortly."
    end    
  end

  def reset_password
    @user = User.find_by_reactivation_code(params[:token])
    if @user.nil?
      redirect_to(:action => 'forgot_password')
      flash[:alert] = "The password reset token is invalid. Please try again."
    else
       
    end

  end

  def save_password
    unless params['password'].empty?
      @user = User.find_by_username(params['username'])
      salt = User.make_salt(@user.username)
      saltedpass = User.hash_with_salt(params['password'], salt)
      @user.salt = salt 
      @user.hashed_password = saltedpass
      @user.reactivation_code = ''
      if @user.save
        redirect_to(:action => 'login')
        flash[:alert] = "You may now login with your new password."          
      end
    end    
  end

end
