defmodule FacebookMessenger.Sender do
  @moduledoc """
  Module responsible for communicating back to facebook messenger
  """
  require Logger

  @doc """
  sends a message to the recepient

    * :recepient - the recepient to send the message to
    * :message - the message to send
  """
  @spec send(String.t, String.t) :: HTTPotion.Response.t
  def send(recepient, message) do
    res = manager.post(
      url: url,
      body: payload(recepient, message) |> to_json_payload
    )

    Logger.info("send: response from FB #{inspect(res)}")

    res
  end

  @spec welcome(String.t) :: HTTPotion.Response.t
  def welcome(message) do
    res = manager.post(
      url: welcome_url,
      body: welcome_payload(message) |> to_json_payload
    )

    Logger.info("welcome_send: response from FB #{inspect(res)}")

    res
  end

  @doc """
  creates a payload to send to facebook

    * :recepient - the recepient to send the message to
    * :message - the message to send
  """
  def payload(recepient, message) do
    %{
      recipient: %{id: recepient},
      message: create_message(message)
    }
  end

  @doc """
  creates a welcome payload to send to facebook

    * :message - the message to send
  """
  def welcome_payload(message) do
    %{
      setting_type: "call_to_actions",
      thread_state: "new_thread",
      call_to_actions: [
        %{ message: message }
      ]
    }
  end

  @doc """
  creates a json payload to send to facebook

    * :recepient - the recepient to send the message to
    * :message - the message to send
  """
  def to_json_payload(payload) do
    payload
    |> Poison.encode
    |> elem(1)
  end

  @doc """
  return the url to hit to send the message
  """
  def url do
    api_uri <> "/messages?access_token=" <> page_token
  end

  @doc """
  return the welcome_url to hit to send the message
  """
  def welcome_url do
    api_uri <> "/thread_settings?access_token=" <> page_token
  end

  defp create_message(%{} = message) do
    message
  end

  defp create_message(message) do
    %{text: message}
  end

  defp api_uri, do: Application.get_env(:facebook_messenger, :api_uri)

  defp page_token, do: Application.get_env(:facebook_messenger, :facebook_page_token)

  defp manager, do: Application.get_env(:facebook_messenger, :request_manager) || FacebookMessenger.RequestManager
end
