module AppLogger
  def self.notify_exception(exception, extra_context: {})
    Rails.logger.error(
      message: exception.message,
      backtrace: exception.backtrace.first(5),
      context: extra_context
    )
  end

  def self.notify_message(message, extra_context: {})
    Rails.logger.warn(
      message: message,
      context: extra_context
    )
  end
end