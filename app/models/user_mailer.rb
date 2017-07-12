class UserMailer < ActionMailer::Base

   def contact(recipient, subject, message)
      @subject = subject
      @recipients = recipient
      @from = 'noreply@perlaairlines.com'
  	  @body["email"] = 'noreply@perlaairlines.com'
   	  @body["message"] = message
      @headers = {}
      @content_type = "text/html"
   end

end
