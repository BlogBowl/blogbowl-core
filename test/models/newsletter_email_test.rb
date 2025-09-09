require_relative "../test_helper"

class NewsletterEmailTest < ActiveSupport::TestCase

  test "should create email" do
    email = newsletters(:one).newsletter_emails.new(subject: "This is a test title", content_html: "This is a test content")
    assert email.save, email.errors.full_messages
  end

  test "should generate slug on create" do
    subject = "This is a test title"
    email = newsletters(:one).newsletter_emails.new(subject: subject, content_html: "This is a test content")
    email.save

    assert_equal email.subject, subject
    assert_equal email.slug, subject.parameterize
  end

  test "should generate slug on update" do
    subject = "Created new subject"
    email = newsletters(:one).newsletter_emails.new(subject: subject, content_html: "This is a test content")
    email.save

    assert_equal email.subject, subject
    assert_equal email.slug, subject.parameterize

    updated_subject = "Updated subject"
    email.update(subject: updated_subject)

    assert_equal email.subject, updated_subject
    assert_equal email.slug, updated_subject.parameterize
  end

  test "similar slug can exist across different newsletters" do
    subject = "New subject"
    email_newsletter_one = newsletters(:one).newsletter_emails.new(subject: subject, content_html: "This is a test content")
    email_newsletter_one.save

    email_workspace_two = newsletters(:two).newsletter_emails.new(subject: subject, content_html: "This is a test content")
    email_workspace_two.save

    assert_equal email_newsletter_one.subject, subject
    assert_equal email_newsletter_one.slug, subject.parameterize

    assert_equal email_workspace_two.subject, subject
    assert_equal email_workspace_two.slug, subject.parameterize
  end

  test "similar slug can not exist across one workspaces" do
    subject = "New subject"
    email_newsletter_one = newsletters(:one).newsletter_emails.new(subject: subject, content_html: "This is a test content")
    email_newsletter_one.save

    email_newsletter_two = newsletters(:one).newsletter_emails.new(subject: subject, content_html: "This is a test content")
    email_newsletter_two.save

    assert_equal email_newsletter_one.subject, subject
    assert_equal email_newsletter_one.slug, subject.parameterize

    assert_equal email_newsletter_two.subject, subject
    assert_not_equal email_newsletter_two.slug, subject.parameterize
  end

  test "if slug exists, it should add number after slug" do
    subject = "New subject"
    email_newsletter_one = newsletters(:one).newsletter_emails.new(subject: subject, content_html: "This is a test content")
    email_newsletter_one.save

    assert_equal email_newsletter_one.subject, subject
    assert_equal email_newsletter_one.slug, subject.parameterize

    5.times do |index|
      current_email = newsletters(:one).newsletter_emails.new(subject: subject, content_html: "This is a test content")
      current_email.save

      assert_equal current_email.subject, subject
      assert_equal current_email.slug, "#{subject.parameterize}-#{index + 1}"
    end
  end

  test "should create default slug" do
    email_newsletter_one = newsletters(:one).newsletter_emails.new(content_html: "This is a test content")
    email_newsletter_one.save

    assert_nil email_newsletter_one.subject
    assert_not_nil email_newsletter_one.slug
  end

end
