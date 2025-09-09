require_relative "../../../test_helper"

class DomainControllerTest < ActionDispatch::IntegrationTest
  DOMAIN_PREFIX = 'mail.blogbowl.io'.freeze

  setup do
    @user = sign_in_as(users(:lazaro_nixon))
  end

  teardown do
    sleep 1 # Wait 1 second before running the next test
  end

  test "should create default domain" do
    @newsletter = newsletters(:one)

    patch newsletters_settings_newsletter_domain_path(@newsletter), params: { newsletter_setting: { domain: DOMAIN_PREFIX } }

    assert_redirected_to edit_newsletters_settings_newsletter_domain_path

    newsletter_setting = @newsletter.settings
    assert_equal newsletter_setting.domain, DOMAIN_PREFIX
    assert_nil newsletter_setting.postmark_domain_id
  end

  test "should create domain" do
    @newsletter = newsletters(:one)

    test_domain = "test-domain-1.com"

    patch newsletters_settings_newsletter_domain_path(@newsletter), params: { newsletter_setting: { domain: test_domain } }

    assert_redirected_to edit_newsletters_settings_newsletter_domain_path

    newsletter_setting = @newsletter.settings
    assert_equal newsletter_setting.domain, test_domain
    assert_not_nil newsletter_setting.postmark_domain_id

    delete_domain(newsletter_setting.postmark_domain_id)
  end

  test "should overwrite domain" do
    @newsletter = newsletters(:one)

    test_domain_1 = "test-domain-2.com"
    test_domain_2 = "test-domain-3.com"

    patch newsletters_settings_newsletter_domain_path(@newsletter), params: { newsletter_setting: { domain: test_domain_1 } }

    assert_redirected_to edit_newsletters_settings_newsletter_domain_path

    test_domain_1_id = @newsletter.settings.postmark_domain_id
    assert_equal @newsletter.settings.domain, test_domain_1

    patch newsletters_settings_newsletter_domain_path(@newsletter), params: { newsletter_setting: { domain: test_domain_2 } }

    assert_redirected_to edit_newsletters_settings_newsletter_domain_path

    newsletter_settings = @newsletter.settings.reload
    assert_equal newsletter_settings.domain, test_domain_2
    assert_not_equal newsletter_settings.postmark_domain_id, test_domain_1_id

    delete_domain(newsletter_settings.postmark_domain_id)
  end

  test "should not overwrite domain" do
    @newsletter = newsletters(:one)

    test_domain_1 = "test-domain-4.com"

    patch newsletters_settings_newsletter_domain_path(@newsletter), params: { newsletter_setting: { domain: test_domain_1 } }

    assert_redirected_to edit_newsletters_settings_newsletter_domain_path

    test_domain_1_id = @newsletter.settings.postmark_domain_id
    assert_equal @newsletter.settings.domain, test_domain_1

    patch newsletters_settings_newsletter_domain_path(@newsletter), params: { newsletter_setting: { domain: test_domain_1 } }

    assert_redirected_to edit_newsletters_settings_newsletter_domain_path

    newsletter_settings = @newsletter.settings.reload
    assert_equal newsletter_settings.domain, test_domain_1
    assert_equal newsletter_settings.postmark_domain_id, test_domain_1_id

    delete_domain(newsletter_settings.postmark_domain_id)
  end

  test "should not allow same domain across multiple workspaces" do
    @newsletter = newsletters(:one)

    test_domain_1 = "test-domain-5.com"

    patch newsletters_settings_newsletter_domain_path(@newsletter), params: { newsletter_setting: { domain: test_domain_1 } }

    assert_redirected_to edit_newsletters_settings_newsletter_domain_path

    test_domain_1_id = @newsletter.settings.postmark_domain_id
    assert_equal @newsletter.settings.domain, test_domain_1

    @user = sign_in_as(users(:alex_gonzalez))
    newsletter_two = newsletters(:two)

    patch newsletters_settings_newsletter_domain_path(newsletter_two), params: { newsletter_setting: { domain: test_domain_1 } }

    assert_response :unprocessable_entity

    newsletter_settings = newsletter_two.settings.reload
    assert_not_equal newsletter_settings.domain, test_domain_1
    assert_not_equal newsletter_settings.postmark_domain_id, test_domain_1_id
    assert_equal flash[:alert], "There was an error updating domain. If the problem persists, please, contact support."

    delete_domain(test_domain_1_id)
  end

  private

  def delete_domain(postmark_domain_id)
    account_token = ENV.fetch('POSTMARK_ACCOUNT_TOKEN', Rails.application.credentials[Rails.env.to_sym][:postmark][:account_token])
    client = Postmark::AccountApiClient.new(account_token)

    client.delete_domain(postmark_domain_id)
  end

end