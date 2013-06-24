class NewUserAccount < ActionMailer::Base
  default :from => "from@example.com"
  def send_info(user)
    @user = user
    mail(:to => 'baerimagery@fs.fed.us', :subject => 'A new account was created in the BIRCH system', :from => 'baer.imagery.support@fs.fed.us')
  end
end
