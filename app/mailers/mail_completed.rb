class MailCompleted < ActionMailer::Base
  def completed_request(request)
    @request = request
    mail(:to => request.requestor_email, :subject => 'Your BAER Imagery/Mapping Request has been completed', :from => 'baerimagery@fs.fed.us')
  end
end
