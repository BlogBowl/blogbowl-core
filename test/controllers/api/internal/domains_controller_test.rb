require_relative "../../../test_helper"

class API::Internal::DomainsControllerTest < ActionDispatch::IntegrationTest
  test "should return not found if no such domain exists" do
    get api_internal_domain_verify_url, params: { domain: 'unverifiable.com' }
    assert_response :not_found
  end

  test "should return ok if domain exists" do
    get api_internal_domain_verify_url, params: { domain: pages(:one).domain }
    assert_response :ok
  end
end
