require_relative "../../../test_helper"
require "minitest/mock"
require 'postmark'

class DomainControllerTest < ActionDispatch::IntegrationTest
  DOMAIN_PREFIX = 'mail.blogbowl.io'.freeze

  setup do
    @user = sign_in_as(users(:lazaro_nixon))
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
    expected_postmark_id = 12345

    mock_postmark_client = Minitest::Mock.new
    mock_postmark_client.expect(:create_domain, { id: expected_postmark_id, name: test_domain }, [{ name: test_domain }])

    Postmark::AccountApiClient.stub :new, mock_postmark_client do
      patch newsletters_settings_newsletter_domain_path(@newsletter), params: { newsletter_setting: { domain: test_domain } }
    end

    assert_redirected_to edit_newsletters_settings_newsletter_domain_path

    newsletter_setting = @newsletter.settings
    assert_equal test_domain, newsletter_setting.domain
    assert_equal expected_postmark_id, newsletter_setting.postmark_domain_id
  end

  test "should overwrite domain" do
    @newsletter = newsletters(:one)

    test_domain_1 = "test-domain-2.com"
    test_domain_2 = "test-domain-3.com"
    postmark_id_1 = 222
    postmark_id_2 = 333

    # First, create the initial domain
    mock_create_client = Minitest::Mock.new
    mock_create_client.expect(:create_domain, { id: postmark_id_1, name: test_domain_1 }, [{ name: test_domain_1 }])

    Postmark::AccountApiClient.stub :new, mock_create_client do
      patch newsletters_settings_newsletter_domain_path(@newsletter), params: { newsletter_setting: { domain: test_domain_1 } }
    end

    mock_create_client.verify
    assert_redirected_to edit_newsletters_settings_newsletter_domain_path
    assert_equal postmark_id_1, @newsletter.settings.reload.postmark_domain_id
    assert_equal @newsletter.settings.domain, test_domain_1

    mock_overwrite_client = Minitest::Mock.new
    mock_overwrite_client.expect(:delete_domain, true, [postmark_id_1])
    mock_overwrite_client.expect(:create_domain, { id: postmark_id_2, name: test_domain_2 }, [{ name: test_domain_2 }])

    Postmark::AccountApiClient.stub :new, mock_overwrite_client do
      patch newsletters_settings_newsletter_domain_path(@newsletter), params: { newsletter_setting: { domain: test_domain_2 } }
    end

    mock_overwrite_client.verify
    assert_redirected_to edit_newsletters_settings_newsletter_domain_path

    newsletter_settings = @newsletter.settings.reload
    assert_equal test_domain_2, newsletter_settings.domain
    assert_equal postmark_id_2, newsletter_settings.postmark_domain_id
  end

  test "should not overwrite domain" do
    @newsletter = newsletters(:one)

    test_domain_1 = "test-domain-4.com"
    postmark_id_1 = 444

    # Mock the initial creation
    mock_create_client = Minitest::Mock.new
    mock_create_client.expect(:create_domain, { id: postmark_id_1, name: test_domain_1 }, [{ name: test_domain_1 }])
    Postmark::AccountApiClient.stub :new, mock_create_client do
      patch newsletters_settings_newsletter_domain_path(@newsletter), params: { newsletter_setting: { domain: test_domain_1 } }
    end
    mock_create_client.verify

    # Submit the form again with the same domain.
    # This time, the controller logic should NOT call the Postmark client at all.
    # We can verify this by stubbing .new to raise an error. If the test passes,
    # it means .new was never called.
    Postmark::AccountApiClient.stub :new, -> { raise "Postmark client should not be initialized!" } do
      patch newsletters_settings_newsletter_domain_path(@newsletter), params: { newsletter_setting: { domain: test_domain_1 } }
    end

    assert_redirected_to edit_newsletters_settings_newsletter_domain_path

    newsletter_settings = @newsletter.settings.reload
    assert_equal test_domain_1, newsletter_settings.domain
    assert_equal postmark_id_1, newsletter_settings.postmark_domain_id
  end

  test "should not allow same domain across multiple workspaces" do
    @newsletter = newsletters(:one)

    test_domain_1 = "test-domain-4.com"
    postmark_id_1 = 444

    mock_create_client = Minitest::Mock.new
    mock_create_client.expect(:create_domain, { id: postmark_id_1, name: test_domain_1 }, [{ name: test_domain_1 }])
    Postmark::AccountApiClient.stub :new, mock_create_client do
      patch newsletters_settings_newsletter_domain_path(@newsletter), params: { newsletter_setting: { domain: test_domain_1 } }
    end

    mock_create_client.verify
    assert_redirected_to edit_newsletters_settings_newsletter_domain_path

    test_domain_1_id = @newsletter.settings.postmark_domain_id
    assert_equal @newsletter.settings.domain, test_domain_1

    @user = sign_in_as(users(:alex_gonzalez))
    newsletter_two = newsletters(:two)

    Postmark::AccountApiClient.stub :new, mock_create_client do
      patch newsletters_settings_newsletter_domain_path(newsletter_two), params: { newsletter_setting: { domain: test_domain_1 } }
    end

    assert_response :unprocessable_entity

    newsletter_settings = newsletter_two.settings.reload
    assert_not_equal newsletter_settings.domain, test_domain_1
    assert_not_equal newsletter_settings.postmark_domain_id, test_domain_1_id
    assert_equal flash[:alert], "There was an error updating domain. If the problem persists, please, contact support."
  end
end