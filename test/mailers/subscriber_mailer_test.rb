require_relative "../test_helper"

class SubscriberMailerTest < ActionMailer::TestCase
  setup do
    @subscriber = subscribers(:unverified)
  end

  test "verification_email" do
    # TODO: Add test for checking email, body, sent from, since user will have control over it

    mail = SubscriberMailer.verification_email(@subscriber, "test.com")
    assert_equal [@subscriber.email], mail.to
  end

end
