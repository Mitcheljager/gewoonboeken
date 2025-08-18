module LogMessage
  def self.log_error_block(message: "", error:)
    Rails.logger.error("\e[31m")
    Rails.logger.error(message) unless message.empty?
    Rails.logger.error("#{error.class}: #{error.message}")
    Rails.logger.error(error.backtrace&.join("\n"))
    Rails.logger.error("\e[0m")
  end
end
