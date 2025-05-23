module StructuredDataHelper
  def article_structured_data(article, breadcrumbs)
    content_tag(:script, post_structured_data_objects(article, breadcrumbs).to_json.html_safe, type: 'application/ld+json')
  end

  def profile_structured_data(author, breadcrumbs)
    content_tag(:script, profile_structured_data_objects(author, breadcrumbs).to_json.html_safe, type: 'application/ld+json')
  end

  def category_structured_data(category, breadcrumbs)
    content_tag(:script, category_structured_data_object(category, breadcrumbs).to_json.html_safe, type: 'application/ld+json')
  end

  def main_structured_data
    content_tag(:script, main_structured_data_objects.to_json.html_safe, type: 'application/ld+json')
  end

  private

  # structured data combined per entity

  def main_structured_data_objects
    {
      "@context": "https://schema.org",
      "@graph": [
        website_data,
        organization_data,
      ]
    }
  end

  def post_structured_data_objects(article, breadcrumbs)
    {
      "@context": "https://schema.org",
      "@graph": [
        article_data(article),
        web_page_data(article),
        website_data,
        organization_data,
        primary_image(article),
        breadcrumbs_data(breadcrumbs),
        *article.authors.map { |author| author_data(author) },
      ]
    }
  end

  def profile_structured_data_objects(author, breadcrumbs)
    {
      "@context": "https://schema.org",
      "@graph": [
        profile_page_data(author),
        website_data,
        organization_data,
        author_data(author),
        breadcrumbs_data(breadcrumbs)
      ]
    }
  end

  def category_structured_data_object(category, breadcrumbs)
    {
      "@context": "https://schema.org",
      "@graph": [
        category_data(category),
        website_data,
        organization_data,
        breadcrumbs_data(breadcrumbs)
      ]
    }
  end

  # structured data combined per entity

  def article_data(article)
    {
      "@type": "Article",
      "@id": "#{get_full_url(dynamic_prefix(public_post_path(article)))}/#article",
      "isPartOf": {
        "@id": get_full_url(dynamic_prefix(public_post_path(article)))
      },
      "author": article.authors.map do |author|
        {
          "@id": "#{get_full_url(dynamic_prefix(''))}/#/schema/person/#{author.slug}"
        }
      end,
      "headline": article.title,
      "datePublished": article.first_published_at,
      "dateModified": article.updated_at,
      "mainEntityOfPage": {
        "@id": get_full_url(dynamic_prefix(public_post_path(article)))
      },
      "wordCount": get_amount_of_words(article),
      "publisher": {
        "@id": "#{get_full_url(dynamic_prefix(''))}/#organization"
      },
      "image": article.images.any? ? {
        "@id": "#{get_full_url(dynamic_prefix(public_post_path(article)))}/#primaryimage"
      } : nil,
      "thumbnailUrl": article.cover_image.present? ? Rails.application.routes.url_helpers.url_for(article.cover_image) : nil,
      "articleSection": article.category.present? ? [
        article.category.name
      ] : [],
      "inLanguage": @workspace_settings.locale,
    }
  end

  def web_page_data(article)
    {
      "@type": "WebPage",
      "@id": get_full_url(dynamic_prefix(public_post_path(article))),
      "url": get_full_url(dynamic_prefix(public_post_path(article))),
      "name": article.title,
      "isPartOf": {
        "@id": "#{get_full_url(dynamic_prefix(''))}/#website"
      },
      "primaryImageOfPage": article.images.any? ? {
        "@id": "#{get_full_url(dynamic_prefix(public_post_path(article)))}/#primaryimage"
      } : nil,
      "image": article.images.any? ? {
        "@id": "#{get_full_url(dynamic_prefix(public_post_path(article)))}/#primaryimage"
      } : nil,
      "thumbnailUrl": article.cover_image.present? ? Rails.application.routes.url_helpers.url_for(article.cover_image) : nil,
      "datePublished": article.first_published_at,
      "dateModified": article.updated_at,
      "description": article.seo_description || article.description,
      "inLanguage": @workspace_settings.locale,
      "potentialAction": [
        {
          "@type": "ReadAction",
          "target": [get_full_url(dynamic_prefix(public_post_path(article)))]
        }
      ],
      "reviewedBy": article.reviewers.map do |reviewer|
        author_data(reviewer)
      end
    }
  end

  def website_data
    {
      "@type": "WebSite",
      "@id": "#{get_full_url(dynamic_prefix(''))}/#website",
      "url": "#{get_full_url(dynamic_prefix(''))}",
      "name": @page_settings.name,
      "description": @page_settings.description,
      "publisher": {
        "@id": "#{get_full_url(dynamic_prefix(''))}/#organization"
      },
      "potentialAction": [
        {
          "@type": "SearchAction",
          "target": {
            "@type": "EntryPoint",
            "urlTemplate": get_full_url(dynamic_prefix('archive/?s={search_term_string}'))
          },
          "query-input": {
            "@type": "PropertyValueSpecification",
            "valueRequired": true,
            "valueName": "search_term_string"
          }
        }
      ],
      "inLanguage": @workspace_settings.locale,
    }
  end

  def organization_data
    {
      "@type": "Organization",
      "@id": "#{get_full_url(dynamic_prefix(''))}/#organization",
      "name": @page_settings.name,
      "url": "#{get_full_url(dynamic_prefix(''))}",
      "logo": @page_settings.logo.present? ? {
        "@type": "ImageObject",
        "inLanguage": @workspace_settings.locale,
        "@id": "#{get_full_url(dynamic_prefix(''))}/#/schema/logo/image/",
        "url": Rails.application.routes.url_helpers.url_for(@page_settings.logo),
        "contentUrl": Rails.application.routes.url_helpers.url_for(@page_settings.logo),
        "width": @page_settings.logo.metadata["width"],
        "height": @page_settings.logo.metadata["height"],
        "caption": @page_settings.name
      } : nil,
      "image": {
        "@id": "#{get_full_url(dynamic_prefix(''))}/#/schema/logo/image/"
      },
      "sameAs": @social_media_links.map(&:url).compact
    }
  end

  def primary_image(article)
    if (image = article.images.first)
      {
        "@type": "ImageObject",
        "inLanguage": @workspace_settings.locale,
        "@id": "#{get_full_url(dynamic_prefix(public_post_path(article)))}/#primaryimage",
        "url": Rails.application.routes.url_helpers.url_for(image),
        "contentUrl": Rails.application.routes.url_helpers.url_for(image),
        "width": image.metadata["width"],
        "height": image.metadata["height"],
        # TODO: Add image alt here instead of article title
        "caption": article.title
      }
    end
  end

  def author_data(author)
    {
      "@type": "Person",
      "@id": "#{get_full_url(dynamic_prefix(''))}/#/schema/person/#{author.slug}",
      "name": author.formatted_name,
      "image": author.avatar_picture.present? ? {
        "@type": "ImageObject",
        "inLanguage": @workspace_settings.locale,
        "@id": "#{get_full_url(dynamic_prefix(''))}/#/schema/person/image/#{author.slug}",
        "url": Rails.application.routes.url_helpers.url_for(author.avatar_picture),
        "contentUrl": Rails.application.routes.url_helpers.url_for(author.avatar_picture),
        "caption": author.formatted_name
      } : nil,
      "description": author.long_description,
      "sameAs": author.author_links.map(&:url).compact,
      "url": get_full_url(dynamic_prefix("/authors/#{author.slug}"))
    }
  end

  def profile_page_data(author)
    {
      "@type": "ProfilePage",
      "@id": get_full_url(dynamic_prefix("/authors/#{author.slug}")),
      "url": get_full_url(dynamic_prefix("/authors/#{author.slug}")),
      "name": "#{author.formatted_name}, Author at #{@page_settings.name}",
      "isPartOf": {
        "@id": "#{get_full_url(dynamic_prefix(''))}/#website"
      },
      "description": "#{author.formatted_name}, Author at #{@page_settings.name}",
      "inLanguage": @workspace_settings.locale,
      "potentialAction": [
        {
          "@type": "ReadAction",
          "target": [
            get_full_url(dynamic_prefix("/authors/#{author.slug}"))
          ]
        }
      ]
    }
  end

  def category_data(category)
    {
      "@type": "CollectionPage",
      "@id": get_category_url(category),
      "url": get_category_url(category),
      "name": category.name,
      "isPartOf": {
        "@id": "#{get_full_url(dynamic_prefix(''))}/#website"
      },
      "description": category.description,
      "inLanguage": @workspace_settings.locale,
    }
  end

  def main_page_data
    {
      "@type": "WebPage",
      "@id": get_full_url(dynamic_prefix('')),
      "url": get_full_url(dynamic_prefix('')),
      "name": "#{@page_settings.name} | #{@page_settings.title}",
      "isPartOf": {
        "@id": "#{get_full_url(dynamic_prefix(''))}/#website"
      },
      "about": {
        "@id": "#{get_full_url(dynamic_prefix(''))}/#organization"
      },
      "datePublished": @page_settings.created_at,
      "dateModified": @page_settings.updated_at,
      "description": @page_settings.description,
      "inLanguage": @workspace_settings.locale,
      "potentialAction": [
        {
          "@type": "ReadAction",
          "target": [
            get_full_url(dynamic_prefix(''))
          ]
        }
      ]
    }
  end

  def breadcrumbs_data(links)
    {
      "@type": "BreadcrumbList",
      "itemListElement": links.each_with_index.map do |link, index|
        breadcrumb_item = {
          "@type": "ListItem",
          "position": index + 1,
          "name": link[:title],
          "item": link[:url]
        }
        breadcrumb_item["item"] = link[:url] if link[:url].present?
        breadcrumb_item
      end
    }
  end

end
