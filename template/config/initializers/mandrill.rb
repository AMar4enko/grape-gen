require 'mandrill'

module Mandrill
  constants.select{|c| /Error$/ =~ c.to_s}.each{|const| remove_const(const) }
  class Error < StandardError
  end
  class ValidationError < Error
  end
  class InvalidKeyError < Error
  end
  class PaymentRequiredError < Error
  end
  class UnknownSubaccountError < Error
  end
  class UnknownTemplateError < Error
  end
  class ServiceUnavailableError < Error
  end
  class UnknownMessageError < Error
  end
  class InvalidTagNameError < Error
  end
  class InvalidRejectError < Error
  end
  class UnknownSenderError < Error
  end
  class UnknownUrlError < Error
  end
  class UnknownTrackingDomainError < Error
  end
  class InvalidTemplateError < Error
  end
  class UnknownWebhookError < Error
  end
  class UnknownInboundDomainError < Error
  end
  class UnknownInboundRouteError < Error
  end
  class UnknownExportError < Error
  end
  class IPProvisionLimitError < Error
  end
  class UnknownPoolError < Error
  end
  class NoSendingHistoryError < Error
  end
  class PoorReputationError < Error
  end
  class UnknownIPError < Error
  end
  class InvalidEmptyDefaultPoolError < Error
  end
  class InvalidDeleteDefaultPoolError < Error
  end
  class InvalidDeleteNonEmptyPoolError < Error
  end
  class InvalidCustomDNSError < Error
  end
  class InvalidCustomDNSPendingError < Error
  end
  class MetadataFieldLimitError < Error
  end
  class UnknownMetadataFieldError < Error
  end
end

MandrillMailer.config.api_key = ApplicationSettings.mandrill.api_key