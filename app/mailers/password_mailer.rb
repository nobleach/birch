class PasswordMailer < ActionMailer::Base
  def send_reset(user, url)
    @user = user
    @url = url
    mail(:to => user.email, :subject => 'Password Reset from BAER Imagery Support', :from => 'baerimagery@fs.fed.us')    
  end
end
