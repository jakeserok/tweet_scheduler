class PasswordResetsController < ApplicationController

  def new
  end

  def create
    @user = User.find_by(email: params[:email])

    if @user.present?
      # Send Email via background job 
      PasswordMailer.with(user: @user).reset.deliver_later
    end
    redirect_to root_path, notice: "If an account with that email is found, we will send a link to reset your password."
  end

end