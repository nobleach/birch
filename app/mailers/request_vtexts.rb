class RequestVtexts < ActionMailer::Base
  def send_confirmation(request)
    @request = request
    recipients = ['5052313179@vtext.com']
    mail(:to => recipients.join(','), :subject => '', :from => 'baerimagery@fs.fed.us')      
  end  
end
