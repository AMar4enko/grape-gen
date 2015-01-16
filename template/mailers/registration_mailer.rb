class RegistrationMailer < MandrillMailer::TemplateMailer
  default from: 'welcome@yourdomain.com'

  def registered(user)
    mandrill_mail(
        template: 'registration',
        subject: 'Welcome',
        to: user.email,
        vars: {
            'USER_NAME' => user.display_name,
            'CONFIRMATION_LINK' => user.email_approvement_code
        },
        important: true,
        inline_css: true
    )
  end
end