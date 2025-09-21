module Models::PageConcern
  extend ActiveSupport::Concern

  included do
    belongs_to :workspace
    has_many :members, through: :workspace

    has_many :posts
    has_many :authors, through: :members
    has_many :categories
    has_many :links, dependent: :destroy
    has_many :subscribers, dependent: :nullify

    has_one :settings, dependent: :destroy, class_name: 'PageSetting'

    validates :slug, presence: true
    validates :name_slug, presence: true
    validates :name, presence: true, uniqueness: { scope: :workspace_id }

    before_validation :sanitize_slug
    before_validation :generate_domain, on: :create
    before_validation :generate_slug, if: :name_changed?
    before_save -> { self.domain = domain.downcase if domain.present? }

    DOMAIN_REGEX = /\A(?!-)(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.){0,3}[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\z/
    validates :domain, presence: true, uniqueness: true, format: { with: DOMAIN_REGEX }

    after_create :after_create
  end

  def create_default_first_post(author_id)
    # create simple category
    category = categories.create(name: 'Getting Started', description: 'Helpful guides and tips to get the most out of BlogBowl. Simply change this category after!', slug: 'other', color: '#F26279')

    title = 'Welcome to Your New Blog! ✨'
    content_html = '<h2 id="this-is-your-first-post-created-automatically-to-help-you-get-started-with-blogbowl" data-toc-id="cf043e59-98c4-4bfd-99d4-ee10a1bbe1b7">This is your first post — created automatically to help you get started with Blogbowl <span data-name="rocket" data-type="emoji">🚀</span> </h2><p><strong>Move this post to archive once you familarize yourself with editor!</strong></p><p class="">Writing and publishing posts here is simple, fast, and focused. Let us show you around <span data-name="point_down" data-type="emoji">👇</span> </p><h3 id="write-with-ease" data-toc-id="92669f2b-fc8d-40b7-85c6-9de666512ced"><span data-name="writing_hand" data-type="emoji">✍</span> Write with Ease</h3><p class="">Just start typing. Our editor is distraction-free, so you can focus on your content.<br>Use headings, bold, lists, and more — all with familiar keyboard shortcuts. <strong>Type “/“ to browse options</strong> or <strong>use markdown format</strong> (E.g. ## - for 2nd level heading, ** for bold text).</p><img src="https://app.blogbowl.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NjEsInB1ciI6ImJsb2JfaWQifX0=--489e0f85e62eb9b3d1c771c94446b2e4d5c58ed1/Screenshot%202025-05-11%20at%2012.47.51.webp" data-width="75%" data-align="center" alt="Text formatting options"><h3 id="4c96e27b-3cf6-4f5e-9380-a315fa4f1036" data-toc-id="4c96e27b-3cf6-4f5e-9380-a315fa4f1036"><span data-name="camera_with_flash" data-type="emoji">📸</span> Add Images and Media</h3><p class="">Drag &amp; drop images directly into your post.<br>Want to embed a video or tweet? Just paste the link — we take care of the rest.</p><img src="https://app.blogbowl.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NjIsInB1ciI6ImJsb2JfaWQifX0=--98e2d252e50db85104076be9aa1594027033a0af/write-click-publish.webp" data-width="100%" data-align="center" alt="Easily add Images"><h3 id="851a226e-59e5-48f4-8833-4acdbdc0a430" data-toc-id="851a226e-59e5-48f4-8833-4acdbdc0a430"><span data-name="hammer_and_wrench" data-type="emoji">🛠</span> Format Effortlessly</h3><p class="">Highlight any text to instantly reveal a formatting menu — no extra clicks needed.</p><p class="">Make text <strong>bold</strong>, <em>italic</em>, add <code>inline code</code>, links, lists, and more with just a tap.<br>Prefer shortcuts? Markdown and keyboard commands work too.</p><p class="">Write the way that’s fastest for you.</p><img src="https://app.blogbowl.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NjQsInB1ciI6ImJsb2JfaWQifX0=--439b9519d3135e0cdfe446396a2c8125364713d4/Screenshot%202025-05-11%20at%2012.52.38.webp" data-width="75%" data-align="center" alt="Highlight text for additional formatting options!"><h3 id="9aab86a7-55f0-4cdc-a6f1-df044573322e" data-toc-id="9aab86a7-55f0-4cdc-a6f1-df044573322e"><span data-name="grinning" data-type="emoji">😀</span> Add Emojis Instantly</h3><p class="">Type <code>:</code> and start typing the emoji name — you’ll see a list pop up.<br>Whether it’s <span data-name="sparkles" data-type="emoji">✨</span> or <span data-name="rocket" data-type="emoji">🚀</span>, we’ve got you covered.</p><p class="">Emojis make your posts more expressive and fun — use them anywhere in your content!</p><img src="https://app.blogbowl.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NjYsInB1ciI6ImJsb2JfaWQifX0=--7cd80931c8ac4e5b2cca3069c8928b077734a5c2/Screenshot%202025-05-11%20at%2012.54.05.webp" data-width="75%" data-align="center" alt="Emojis menu"><h3 id="43d9f864-87d3-4523-9a38-ee8b67869696" data-toc-id="43d9f864-87d3-4523-9a38-ee8b67869696"><span data-name="gear" data-type="emoji">⚙</span> Customize Post Details</h3><p class="">Use the right-side menu to fine-tune your post.<br>You can easily update:</p><ul><li><p class=""><strong>Post description</strong></p></li><li><p class=""><strong>Category</strong></p></li><li><p class=""><strong>Author</strong></p></li><li><p class=""><strong>Cover image</strong></p></li></ul><p class="">This helps your post look great and stay organized — all in a few clicks. </p><p class=""><span data-name="white_check_mark" data-type="emoji">✅</span> <strong>Do not forget to click “Save settings!“</strong></p><img src="https://app.blogbowl.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NjksInB1ciI6ImJsb2JfaWQifX0=--6902a837b58508d4f4f7db805a981310771ec1a5/Screenshot%202025-05-11%20at%2012.58.09.webp" data-width="75%" data-align="center" alt="Post settings sidebar"><h3 id="hit-publish!" data-toc-id="70e8218c-266f-44ef-89f3-7db7e8eb7b83"><span data-name="rocket" data-type="emoji">🚀</span> Hit Publish!</h3><p class="">Ready to share? Just click <strong>Publish</strong> — and your post is live, SEO-optimized, and fast.</p><p class="">No setup. No code. Just content.</p><p class=""><strong>Note: Before publishing a post you need to fill description, category and authors.</strong></p><img src="https://app.blogbowl.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NzIsInB1ciI6ImJsb2JfaWQifX0=--ae7f461773ae0b2322cc27bc8510522df8e02bf7/Screenshot%202025-05-11%20at%2013.00.25.webp" data-width="75%" data-align="center" alt="Publishing you post"><h3 id="a52bde20-7cc3-4734-87e2-81a3b861b398" data-toc-id="a52bde20-7cc3-4734-87e2-81a3b861b398"><span data-name="earth_africa" data-type="emoji">🌍</span> View Your Post Live</h3><p class="">Once you hit <strong>Publish</strong>, just click the <strong>globe icon</strong> in the top right corner of the editor.<br>It will open your live blog post in a new tab — ready to share with the world.</p><p class="">No deployments. No waiting. Just live instantly.</p><img src="https://app.blogbowl.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NzQsInB1ciI6ImJsb2JfaWQifX0=--6b05fd4db20de201aa513e458d13039a57893c85/Screenshot%202025-05-11%20at%2013.09.33.webp" data-width="75%" data-align="center" alt="View Your Post Live"><p></p>'
    content_json = JSON.parse('{"type": "doc", "content": [{"type": "heading", "attrs": {"id": "this-is-your-first-post-created-automatically-to-help-you-get-started-with-blogbowl", "level": 2, "textAlign": "left", "data-toc-id": "cf043e59-98c4-4bfd-99d4-ee10a1bbe1b7"}, "content": [{"text": "This is your first post — created automatically to help you get started with Blogbowl ", "type": "text"}, {"type": "emoji", "attrs": {"name": "rocket"}}, {"text": " ", "type": "text"}]}, {"type": "paragraph", "attrs": {"class": null, "textAlign": "left"}, "content": [{"text": "Move this post to archive once you familarize yourself with editor!", "type": "text", "marks": [{"type": "bold"}]}]}, {"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "Writing and publishing posts here is simple, fast, and focused. Let us show you around ", "type": "text"}, {"type": "emoji", "attrs": {"name": "point_down"}}, {"text": " ", "type": "text"}]}, {"type": "heading", "attrs": {"id": "write-with-ease", "level": 3, "textAlign": "left", "data-toc-id": "92669f2b-fc8d-40b7-85c6-9de666512ced"}, "content": [{"type": "emoji", "attrs": {"name": "writing_hand"}}, {"text": " Write with Ease", "type": "text"}]}, {"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "Just start typing. Our editor is distraction-free, so you can focus on your content.", "type": "text"}, {"type": "hardBreak"}, {"text": "Use headings, bold, lists, and more — all with familiar keyboard shortcuts. ", "type": "text"}, {"text": "Type “/“ to browse options", "type": "text", "marks": [{"type": "bold"}]}, {"text": " or ", "type": "text"}, {"text": "use markdown format", "type": "text", "marks": [{"type": "bold"}]}, {"text": " (E.g. ## - for 2nd level heading, ** for bold text).", "type": "text"}]}, {"type": "imageBlock", "attrs": {"alt": "Text formatting options", "src": "https://app.blogbowl.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NjEsInB1ciI6ImJsb2JfaWQifX0=--489e0f85e62eb9b3d1c771c94446b2e4d5c58ed1/Screenshot%202025-05-11%20at%2012.47.51.webp", "align": "center", "width": "75%"}}, {"type": "heading", "attrs": {"id": "4c96e27b-3cf6-4f5e-9380-a315fa4f1036", "level": 3, "textAlign": "left", "data-toc-id": "4c96e27b-3cf6-4f5e-9380-a315fa4f1036"}, "content": [{"type": "emoji", "attrs": {"name": "camera_with_flash"}}, {"text": " Add Images and Media", "type": "text"}]}, {"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "Drag & drop images directly into your post.", "type": "text"}, {"type": "hardBreak"}, {"text": "Want to embed a video or tweet? Just paste the link — we take care of the rest.", "type": "text"}]}, {"type": "imageBlock", "attrs": {"alt": "Easily add Images", "src": "https://app.blogbowl.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NjIsInB1ciI6ImJsb2JfaWQifX0=--98e2d252e50db85104076be9aa1594027033a0af/write-click-publish.webp", "align": "center", "width": "100%"}}, {"type": "heading", "attrs": {"id": "851a226e-59e5-48f4-8833-4acdbdc0a430", "level": 3, "textAlign": "left", "data-toc-id": "851a226e-59e5-48f4-8833-4acdbdc0a430"}, "content": [{"type": "emoji", "attrs": {"name": "hammer_and_wrench"}}, {"text": " Format Effortlessly", "type": "text"}]}, {"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "Highlight any text to instantly reveal a formatting menu — no extra clicks needed.", "type": "text"}]}, {"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "Make text ", "type": "text"}, {"text": "bold", "type": "text", "marks": [{"type": "bold"}]}, {"text": ", ", "type": "text"}, {"text": "italic", "type": "text", "marks": [{"type": "italic"}]}, {"text": ", add ", "type": "text"}, {"text": "inline code", "type": "text", "marks": [{"type": "code"}]}, {"text": ", links, lists, and more with just a tap.", "type": "text"}, {"type": "hardBreak"}, {"text": "Prefer shortcuts? Markdown and keyboard commands work too.", "type": "text"}]}, {"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "Write the way that’s fastest for you.", "type": "text"}]}, {"type": "imageBlock", "attrs": {"alt": "Highlight text for additional formatting options!", "src": "https://app.blogbowl.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NjQsInB1ciI6ImJsb2JfaWQifX0=--439b9519d3135e0cdfe446396a2c8125364713d4/Screenshot%202025-05-11%20at%2012.52.38.webp", "align": "center", "width": "75%"}}, {"type": "heading", "attrs": {"id": "9aab86a7-55f0-4cdc-a6f1-df044573322e", "level": 3, "textAlign": "left", "data-toc-id": "9aab86a7-55f0-4cdc-a6f1-df044573322e"}, "content": [{"type": "emoji", "attrs": {"name": "grinning"}}, {"text": " Add Emojis Instantly", "type": "text"}]}, {"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "Type ", "type": "text"}, {"text": ":", "type": "text", "marks": [{"type": "code"}]}, {"text": " and start typing the emoji name — you’ll see a list pop up.", "type": "text"}, {"type": "hardBreak"}, {"text": "Whether it’s ", "type": "text"}, {"type": "emoji", "attrs": {"name": "sparkles"}}, {"text": " or ", "type": "text"}, {"type": "emoji", "attrs": {"name": "rocket"}}, {"text": ", we’ve got you covered.", "type": "text"}]}, {"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "Emojis make your posts more expressive and fun — use them anywhere in your content!", "type": "text"}]}, {"type": "imageBlock", "attrs": {"alt": "Emojis menu", "src": "https://app.blogbowl.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NjYsInB1ciI6ImJsb2JfaWQifX0=--7cd80931c8ac4e5b2cca3069c8928b077734a5c2/Screenshot%202025-05-11%20at%2012.54.05.webp", "align": "center", "width": "75%"}}, {"type": "heading", "attrs": {"id": "43d9f864-87d3-4523-9a38-ee8b67869696", "level": 3, "textAlign": "left", "data-toc-id": "43d9f864-87d3-4523-9a38-ee8b67869696"}, "content": [{"type": "emoji", "attrs": {"name": "gear"}}, {"text": " Customize Post Details", "type": "text"}]}, {"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "Use the right-side menu to fine-tune your post.", "type": "text"}, {"type": "hardBreak"}, {"text": "You can easily update:", "type": "text"}]}, {"type": "bulletList", "content": [{"type": "listItem", "content": [{"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "Post description", "type": "text", "marks": [{"type": "bold"}]}]}]}, {"type": "listItem", "content": [{"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "Category", "type": "text", "marks": [{"type": "bold"}]}]}]}, {"type": "listItem", "content": [{"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "Author", "type": "text", "marks": [{"type": "bold"}]}]}]}, {"type": "listItem", "content": [{"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "Cover image", "type": "text", "marks": [{"type": "bold"}]}]}]}]}, {"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "This helps your post look great and stay organized — all in a few clicks. ", "type": "text"}]}, {"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"type": "emoji", "attrs": {"name": "white_check_mark"}}, {"text": " ", "type": "text"}, {"text": "Do not forget to click “Save settings!“", "type": "text", "marks": [{"type": "bold"}]}]}, {"type": "imageBlock", "attrs": {"alt": "Post settings sidebar", "src": "https://app.blogbowl.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NjksInB1ciI6ImJsb2JfaWQifX0=--6902a837b58508d4f4f7db805a981310771ec1a5/Screenshot%202025-05-11%20at%2012.58.09.webp", "align": "center", "width": "75%"}}, {"type": "heading", "attrs": {"id": "hit-publish!", "level": 3, "textAlign": "left", "data-toc-id": "70e8218c-266f-44ef-89f3-7db7e8eb7b83"}, "content": [{"type": "emoji", "attrs": {"name": "rocket"}}, {"text": " Hit Publish!", "type": "text"}]}, {"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "Ready to share? Just click ", "type": "text"}, {"text": "Publish", "type": "text", "marks": [{"type": "bold"}]}, {"text": " — and your post is live, SEO-optimized, and fast.", "type": "text"}]}, {"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "No setup. No code. Just content.", "type": "text"}]}, {"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "Note: Before publishing a post you need to fill description, category and authors.", "type": "text", "marks": [{"type": "bold"}]}]}, {"type": "imageBlock", "attrs": {"alt": "Publishing you post", "src": "https://app.blogbowl.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NzIsInB1ciI6ImJsb2JfaWQifX0=--ae7f461773ae0b2322cc27bc8510522df8e02bf7/Screenshot%202025-05-11%20at%2013.00.25.webp", "align": "center", "width": "75%"}}, {"type": "heading", "attrs": {"id": "a52bde20-7cc3-4734-87e2-81a3b861b398", "level": 3, "textAlign": "left", "data-toc-id": "a52bde20-7cc3-4734-87e2-81a3b861b398"}, "content": [{"type": "emoji", "attrs": {"name": "earth_africa"}}, {"text": " View Your Post Live", "type": "text"}]}, {"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "Once you hit ", "type": "text"}, {"text": "Publish", "type": "text", "marks": [{"type": "bold"}]}, {"text": ", just click the ", "type": "text"}, {"text": "globe icon", "type": "text", "marks": [{"type": "bold"}]}, {"text": " in the top right corner of the editor.", "type": "text"}, {"type": "hardBreak"}, {"text": "It will open your live blog post in a new tab — ready to share with the world.", "type": "text"}]}, {"type": "paragraph", "attrs": {"class": "", "textAlign": "left"}, "content": [{"text": "No deployments. No waiting. Just live instantly.", "type": "text"}]}, {"type": "imageBlock", "attrs": {"alt": "View Your Post Live", "src": "https://app.blogbowl.io/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NzQsInB1ciI6ImJsb2JfaWQifX0=--6b05fd4db20de201aa513e458d13039a57893c85/Screenshot%202025-05-11%20at%2013.09.33.webp", "align": "center", "width": "75%"}}, {"type": "paragraph", "attrs": {"class": null, "textAlign": "left"}}]}')

    post = posts.create!(
      title: title,
      content_html: content_html,
      status: 0,
      category_id: category.id,
      slug: 'welcome-to-your-new-blog',
      content_json: content_json,
      description: 'Learn how to use Blogbowl’s editor to write, format, and publish your first post. From adding images to customizing settings — here’s a quick guide to help you get started.',
      page_id: id
    )

    # Attach default cover image - simple approach
    image_path = Rails.root.join('app', 'assets', 'images', 'write-click-publish.webp')
    post.cover_image.attach(io: File.open(image_path), filename: 'write-click-publish.webp', content_type: 'image/webp')

    post.post_authors.create(post_id: post.id, author_id: author_id)
    post.post_revisions.create(
      title: title,
      content_html: content_html,
      content_json: content_json,
      kind: 0
    )
    post.publish!
  rescue => e
    Rails.logger.error "Failed to create default first post: #{e.message}"
    notify_exception(e, extra_context: { workspace_id: id, page_id: id })
  end

  def create_post_with_revision(title, content_html, content_json, description, category_id, author_id, cover_image_url, publish = false)
    require 'open-uri'

    post = posts.create!(
      title: title,
      content_html: content_html,
      status: 0,
      category_id: category_id,
      slug: title.parameterize,
      content_json: content_json,
      description: description,
      page_id: id,
      )

    unless cover_image_url.nil?
      uri = URI.open(cover_image_url)
      post.cover_image.attach(io: uri, filename: "#{title}-cover.webp", content_type: 'image/webp')
    end

    post.post_authors.create(post_id: post.id, author_id: author_id)

    post.post_revisions.create(
      title: title,
      content_html: content_html,
      content_json: content_json,
      kind: 0
    )

    if publish
      res = post.publish!
    end

    post
  end

  def to_param
    name_slug
  end

  private
  def after_create
    newsletter = workspace.newsletters.first

    create_settings(
      logo_text: "My blog",
      title: "Unlocking your blog's potential",
      description: "An expert blog about making best SaaS products.",
      seo_title: "Unlocking your blog's potential",
      seo_description: "An expert blog about making best SaaS products.",
      template: 'blog_1',
      with_sitemap: true,
      with_search: true,
      header_cta_button: 'Sign up!',
      cta_enabled: true,
      cta_title: 'Ready to get started?',
      cta_description: 'Sign up today and explore everything we have to offer!',
      cta_button: 'Sign up!',
      newsletter_cta_enabled: FeatureGuard.enabled?(:postmark),
      newsletter_cta_title: 'Stay in the Loop!',
      newsletter_cta_description: 'Subscribe to our newsletter for the latest updates, tips and stories.',
      newsletter_cta_button: 'Subscribe now!',
      newsletter_cta_disclaimer: 'No spam, unsubscribe anytime',
      newsletter: newsletter
    )

    create_default_links
  end

  def sanitize_slug
    self.slug = slug&.gsub('/', '') # Remove all `/` characters
  end

  def generate_domain
    base_domain = ENV.fetch('BASE_DOMAIN', Rails.application.credentials[Rails.env.to_sym][:base_domain])
    self.domain ||= "#{('a'..'z').to_a.shuffle[0, 10].join}.#{base_domain}"
  end

  def create_default_links
    link_data = [
      { title: "Home", url: "https://www.google.com/", order: 0 },
      { title: "About", url: "https://www.google.com/about", order: 1 },
      { title: "Contact", url: "https://www.google.com/contact", order: 2 }
    ]

    records = %w[header footer].flat_map do |location|
      link_data.map do |link|
        link.merge(link_type: "link", location: location, created_at: Time.now, updated_at: Time.now)
      end
    end

    links.insert_all(records)
    links.insert({ title: "twitter", url: "https://x.com/", order: 0, link_type: 'social_media', location: 'footer' })
  end

  def generate_slug
    base_slug = name.parameterize
    potential_slug = base_slug
    count = 1

    while Page.exists?(slug: potential_slug, workspace_id: workspace_id)
      potential_slug = "#{base_slug}-#{count}"
      count += 1
    end

    self.name_slug = potential_slug
  end

end