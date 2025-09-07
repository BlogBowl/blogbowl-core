module AvatarHelper
  def avatar_placeholder(size: 1, initials: nil, css_class: '')
    avatar_class = case size
                   when 0.5
                     "w-8 text-xs"
                   when 1
                     "w-10 text-md"
                   when 2
                     "w-12 text-lg"
                   when 3
                     "w-14 text-xl"
                   when 4
                     "w-20 text-2xl"
                   when 10
                     "w-60 text-9xl"
                   else
                     "w-10 text-md"
                   end
    <<~HTML
      <div class="avatar avatar-placeholder">
          <div class="bg-gray-500 flex items-center justify-center text-neutral-content rounded-full #{avatar_class} #{css_class}">
              <span>#{initials}</span>
          </div>
      </div>
    HTML
  end

  def avatar_pic(size: 1, picture: nil, alt: "profile pic", css_class: '')
    return unless picture.present?
    variant, variant_class = case size
                                when 0.5
                                  [:sm, "w-8"]
                                when 1
                                  [:sm, "w-10"]
                                when 2
                                  [:sm, "w-12"]
                                when 3
                                  [:md, "w-14"]
                                when 4
                                  [:md, "w-20"]
                                when 10
                                  [:lg, "w-60"]
                                else
                                  [:md, "w-10"]
                             end

    <<~HTML
      <div class="avatar">
        <div class="rounded-full #{variant_class} #{css_class}">
          #{ActionController::Base.helpers.image_tag(Rails.application.routes.url_helpers.url_for(picture.variant(variant)), alt:)}
        </div>
      </div>
    HTML
  end
end
