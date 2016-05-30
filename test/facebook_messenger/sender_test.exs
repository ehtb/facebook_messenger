defmodule TestBotOne.MessageSenderTest do
  use ExUnit.Case

  test "creates a correct url" do
    assert FacebookMessenger.Sender.url == "https://graph.facebook.com/v2.6/me/messages?access_token=PAGE_TOKEN"
  end

  test "creates a correct payload" do
    assert FacebookMessenger.Sender.payload(1055439761215256, "Hello") ==
    %{message: %{text: "Hello"}, recipient: %{id: 1055439761215256}}
  end

  test "creates a correct welcome" do
    assert FacebookMessenger.Sender.welcome_payload("Hello") ==
    %{call_to_actions: [%{message: "Hello"}], setting_type: "call_to_actions", thread_state: "new_thread"}
  end

  test "creates a correct payload in json" do
    payload = FacebookMessenger.Sender.payload(1055439761215256, "Hello")

    assert FacebookMessenger.Sender.to_json_payload(payload) ==
    "{\"recipient\":{\"id\":1055439761215256},\"message\":{\"text\":\"Hello\"}}"
  end

  test "sends correct message" do
    FacebookMessenger.Sender.send(1055439761215256, "Hello")

    assert_received %{body: "{\"recipient\":{\"id\":1055439761215256},\"message\":{\"text\":\"Hello\"}}", url: "https://graph.facebook.com/v2.6/me/messages?access_token=PAGE_TOKEN"}
  end

  test "sends correct welcome" do
    FacebookMessenger.Sender.welcome("Hello")

    assert_received %{body: "{\"thread_state\":\"new_thread\",\"setting_type\":\"call_to_actions\",\"call_to_actions\":[{\"message\":\"Hello\"}]}", url: "https://graph.facebook.com/v2.6/me/thread_settings?access_token=PAGE_TOKEN"}
  end
end
