class UsersController < ApplicationController
  before_filter :confirm_logged_in,
    :except => [:new, :create]

  def index
    @users = User.all
  end

  def new
    @user = User.new  
  end

  def create
    if params[:user][:username] == 'admin'
      redirect_to(:controller => 'users', :action => 'new')
      flash[:error] = "You may not choose Admin as a username!"
    end
    @user = User.new
    salt = User.make_salt(params[:user][:username])
    saltedpass = User.hash_with_salt(params[:user][:password], salt) 
    @user.username = params[:user][:username]
    @user.first_name = params[:user][:first_name]
    @user.last_name = params[:user][:last_name]
    @user.email = params[:user][:email]
    @user.phone = params[:user][:phone]
    @user.salt = salt
    @user.hashed_password = saltedpass
    if @user.save
      NewUserAccount.send_info(@user).deliver
      redirect_to(:controller => 'users', :action => 'index')
      flash[:notice] = "User has been added"
    else
      redirect_to(:controller => 'users', :action => 'index')
      flash[:notice] = "User has NOT been added"
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])     
    @user.username = params[:user][:username]
    @user.first_name = params[:user][:first_name]
    @user.last_name = params[:user][:last_name]
    @user.email = params[:user][:email]
    @user.phone = params[:user][:phone]
    unless params[:user][:password].empty?
      salt = User.make_salt(params[:user][:username])
      saltedpass = User.hash_with_salt(params[:user][:password], salt)
      @user.salt = salt 
      @user.hashed_password = saltedpass
    end    
    if @user.save
      redirect_to(:controller => 'users', :action => 'index')
      flash[:notice] = "User has been updated"
    else
      redirect_to(:controller => 'users', :action => 'index')
      flash[:error] = "User has NOT been updated"
    end
  end

  def show
    @user = User.find(session[:user_id])
    respond_to do |format|
      format.js { render :json => @user.to_json, :callback => params[:callback]}      
    end
  end

  def delete
    @user = User.find(params[:id])
    render( :partial => 'common/userconfirmation' )
  end

  def destroy
    User.find(params[:id]).destroy
    @users = User.all
    redirect_to(:controller => 'users', :action => 'index')
  end

end
