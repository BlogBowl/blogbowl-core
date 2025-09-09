module CoreHelper
  include SocialMediaHelper
  def current_user
    Current.user
  end

  def get_gravatar_url(email)
    email_address = email.downcase

    # Create the SHA256 hash
    hash = Digest::SHA256.hexdigest(email_address)

    # Set default URL and size parameters
    default = "https://www.gravatar.com/avatar/?d=mp"
    size = 200

    # Compile the full URL with URI encoding for the parameters
    params = URI.encode_www_form('d' => 'mp', 's' => size, 'r' => 'g')
    # r=g&d=blank
    "https://www.gravatar.com/avatar/#{hash}?#{params}"
  end

  def step_classes(current_step, step_number)
    if current_step > step_number
      # Completed step
      'bg-primary text-white'
    elsif current_step == step_number
      # Current/active step
      'bg-primary-content text-primary border-2 border-primary'
    else
      # Future/inactive step
      'bg-gray-200 text-gray-500'
    end
  end

  def connector_classes(current_step, step_number)
    if current_step > step_number
      # Connection to completed step
      'bg-primary'
    else
      # Connection to future step
      'bg-gray-200'
    end
  end
end
