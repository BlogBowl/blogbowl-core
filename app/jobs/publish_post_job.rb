class PublishPostJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    post = Post.find(post_id)
    return unless post.scheduled?

    post.publish!
  rescue => e
    AppLogger.notify_exception(e, extra_context: { post_id: post_id })
    raise e
  end
end
