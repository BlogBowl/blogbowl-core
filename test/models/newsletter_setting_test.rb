require_relative "../test_helper"

class NewsletterSettingTest < ActiveSupport::TestCase
  test "should generate sender_email on update" do
    newsletter = newsletters(:one)

    newsletter.settings.update(domain: "test.com", sender: "peter")

    assert_equal newsletter.settings.sender_email, "peter@test.com"

    newsletter.settings.update(domain: "test.com", sender: "peter2")

    assert_equal newsletter.settings.sender_email, "peter2@test.com"

    newsletter.settings.update(domain: "test2.com", sender: "peter2")

    assert_equal newsletter.settings.sender_email, "peter2@test2.com"
  end
end
