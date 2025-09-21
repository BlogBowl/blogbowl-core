require 'digest'
require 'uri'

module CoreApplicationHelper
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


end
