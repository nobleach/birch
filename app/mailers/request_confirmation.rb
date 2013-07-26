class RequestConfirmation < ActionMailer::Base
  def send_confirmation(request)
    @request = request
    recipients = ['crbaker@fs.fed.us', 'baerimagery@fs.fed.us', @request.requestor_email]
    if @request.department == 'Dept of Interior'
      recipients << 'rmckinley@usgs.gov,jpicotte@usgs.gov,smhoward@usgs.gov'
    end
      mail(:to => recipients.join(','), :subject => 'Your BAER Imagery/Mapping Request has been submitted', :from => 'baerimagery@fs.fed.us')
  end
end
