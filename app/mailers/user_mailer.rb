class UserMailer < ApplicationMailer
    # Method for sending verification email
    def verification_email(user)
      @user = user
      @verification_url = verify_email_session_custom_url(token: @user.verification_token, username: @user.username)
      email_subject = 'Verify Your Email'
  
      send_email(user.email, email_subject, 'user_mailer/verification_email')
    end
  
    # Method for sending password reset instructions email
    def password_reset_instructions(user)
      @user = user
      @reset_password_url = edit_password_reset_url(@user.password_reset_token, @user.username)
      email_subject = 'Password Reset Instructions'
  
      send_email(user.email, email_subject, 'user_mailer/password_reset_instructions')
    end
  
    private
  
    # Private method to send an email
    def send_email(to_address, subject, template)
      email_body = render_to_string(template: template, layout: nil)
  
      ses_client = Aws::SES::Client.new
  
      ses_client.send_email({
        source: 'noreply@owlabs.online', # Replace with your sender email
        destination: {
          to_addresses: [to_address]
        },
        message: {
          subject: {
            data: subject
          },
          body: {
            html: {
              data: email_body
            }
          }
        }
      })
    end
  end
  