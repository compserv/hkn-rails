Rails.configuration.stripe = {
  :publishable_key => 'pk_test_ztG0Mq5xpCpsvGPuvrJf8D4B',
  :secret_key      => 'sk_test_frlcKbk3tCGoVXf5crFf4AUm'
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]