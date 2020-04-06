class JsonWebToken
  # Rails application unique secret key
  HMAC_SECRET = Rails.application.secrets.secret_key_base.freeze

  # Encodes token based on a payload and expiration date
  # which is in 24 hours from creation time
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, HMAC_SECRET)
  end

  # Gets the payload, which is the first index in decoded Array
  # and attempts to decode the token with the same secret used in encoding
  # If the decoding fails due to validation or expiration, the exceptions
  # will be caught and handled in the ExceptionHandler module
  def self.decode(token)
    body = JWT.decode(token, HMAC_SECRET)[0]
    HashWithIndifferentAccess.new body

  rescue JWT::DecodeError => e
    raise ExceptionHandler::InvalidToken, e.message
  end
end
