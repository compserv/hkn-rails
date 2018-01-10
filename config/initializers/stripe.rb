Rails.configuration.stripe = {
  publishable_key: Rails.application.secrets.stripe_pub_key,
  secret_key:      Rails.application.secrets.stripe_secret_key
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
