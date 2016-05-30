# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger,
  level: :info

case Mix.env do
  :test ->
    config :facebook_messenger,
      facebook_page_token: "PAGE_TOKEN",
      challenge_verification_token: "VERIFY_TOKEN",
      endpoint: "/messenger/webhook",
      request_manager: FacebookMessenger.RequestManager.Mock,
      api_uri: "https://graph.facebook.com/v2.6/me"

  :dev ->
    config :facebook_messenger,
      facebook_page_token: "PAGE_TOKEN",
      challenge_verification_token: "VERIFY_TOKEN",
      endpoint: "/messenger/webhook",
      request_manager: FacebookMessenger.RequestManager,
      api_uri: "https://graph.facebook.com/v2.6/me"

  _ -> true
end
