module SocialMediaHelper
  def social_media_icon(platform)
    case platform.to_s.downcase
    when "twitter"
      "iconoir-x"
    when "facebook"
      "iconoir-facebook"
    when "instagram"
      "iconoir-instagram"
    when "linkedin"
      "iconoir-linkedin"
    when "youtube"
      "iconoir-youtube"
    when "pinterest"
      "iconoir-pinterest"
    when "tiktok"
      "iconoir-tiktok"
    when "telegram"
      "iconoir-telegram"
    when "discord"
      "iconoir-discord"
    when "mastodon"
      "iconoir-mastodon"
    when "github"
      "iconoir-github"
    else
      "iconoir-link"
    end
  end
end
