require_relative "../test_helper"

class SubscriberTest < ActiveSupport::TestCase
  test "should not save subscriber with invalid email" do
    newsletter = newsletters(:one)

    subscriber = Subscriber.create(email: "wrong email", status: 'pending', active: false, verified: false, newsletter: newsletter)
    assert_not subscriber.save
  end

  test "should save subscriber with valid email" do
    newsletter = newsletters(:one)

    subscriber = Subscriber.create(email: "valid@email.com", status: 'pending', active: false, verified: false, newsletter: newsletter)
    assert subscriber.save, subscriber.errors.full_messages
  end

  test "should not save duplicate email, if it already exists in newsletter" do
    newsletter = newsletters(:one)
    existing_subscriber = subscribers(:one)

    duplicate_subscriber = Subscriber.create(email: existing_subscriber.email, status: 'pending', active: false, verified: false, newsletter: newsletter)

    assert_not duplicate_subscriber.save
  end

  test "should save duplicate email, if it does not exist in newsletter" do
    newsletter = newsletters(:two)
    existing_subscriber = subscribers(:one)

    duplicate_subscriber = Subscriber.create(email: existing_subscriber.email, status: 'pending', active: false, verified: false, newsletter: newsletter)

    assert duplicate_subscriber.save, duplicate_subscriber.errors.full_messages
  end

  test "verify subscriber" do
    unverified_subscriber = subscribers(:one)

    unverified_subscriber.verification_token = SecureRandom.urlsafe_base64
    unverified_subscriber.verification_email_sent_at = Time.current

    assert_not unverified_subscriber.active
    assert_not unverified_subscriber.verified
    assert_equal unverified_subscriber.status, "pending"
    assert_nil unverified_subscriber.verified_at
    assert_not_nil unverified_subscriber.verification_token
    assert_not_nil unverified_subscriber.verification_email_sent_at

    unverified_subscriber.verify

    assert unverified_subscriber.active
    assert unverified_subscriber.verified
    assert_equal unverified_subscriber.status, "active"
    assert_not_nil unverified_subscriber.verified_at
    assert_nil unverified_subscriber.verification_token
    assert_nil unverified_subscriber.verification_email_sent_at
  end

  test "suppress subscriber" do
    subscriber = subscribers(:two)
    subscriber.verify

    assert subscriber.active
    assert subscriber.verified
    assert_not_nil subscriber.verified_at
    assert_equal subscriber.status, "active"
    assert_nil subscriber.suppressed_at

    subscriber.suppress("ManualSuppression")
    assert_not subscriber.active
    assert subscriber.verified
    assert_equal subscriber.status, "suppressed"
    assert_equal subscriber.suppression_reason, "ManualSuppression"
    assert_not_nil subscriber.suppressed_at

  end
end
