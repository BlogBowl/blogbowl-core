Truemail.configure do |config|
  # Required parameter. You can use your own email for this.
  # It will be used as the sender for SMTP validation.
  config.verifier_email = 'noreply-valid@blogbowl.io'

  config.default_validation_type = :mx # ✅ ADD THIS LINE

  # Define which validation types to use.
  # The order matters: it will stop on the first failure.
  config.validation_type_for = {
    'gmail.com'      => :smtp,
    'googlemail.com' => :smtp,
    'hotmail.com'    => :smtp,
    'outlook.com'    => :smtp,
    'yahoo.com'      => :smtp
  }

  config.smtp_safe_check = true
end