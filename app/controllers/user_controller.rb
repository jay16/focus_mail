class UserController < ApplicationController
  def edit
    @user = current_user
  end
  
  def update_password
    puts "====================================="
    puts params[:user][:password]
    @user = current_user#User.find(current_user.id)
    puts @user.to_json
    puts @user.update_attributes(params[:user])
    puts "====================================="
    if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      # Sign in the user by passing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to root_path
    else
      puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      render "edit"
    end
  end
end
