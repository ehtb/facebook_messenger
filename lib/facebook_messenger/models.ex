defmodule FacebookMessenger.Attachment do
  @moduledoc """
  Messenger attachment structure
  """
  @derive [Poison.Encoder]
  defstruct [:type, :title, :payload, :url]

  @type t :: %FacebookMessenger.Attachment{
    type: atom,
    title: String.t,
    payload: %{},
    url: String.t
  }
end

defmodule FacebookMessenger.Message do
  @moduledoc """
  Facebook message structure
  """

  @derive [Poison.Encoder]
  defstruct [:mid, :seq, :text, :attachments]

  @type t :: %FacebookMessenger.Message{
    mid: String.t,
    seq: integer,
    text: String.t,
    attachments: [FacebookMessenger.Attachment.t]
  }
end

defmodule FacebookMessenger.User do
  @moduledoc """
  Facebook user structure
  """

  @derive [Poison.Encoder]
  defstruct [:id]

  @type t :: %FacebookMessenger.User{
    id: String.t
  }
end

defmodule FacebookMessenger.Optin do
  @moduledoc """
  Facebook user structure
  """

  @derive [Poison.Encoder]
  defstruct [:ref]

  @type t :: %FacebookMessenger.Optin{
    ref: String.t
  }
end

defmodule FacebookMessenger.Postback do
  @moduledoc """
  Facebook postback structure
  """

  @derive [Poison.Encoder]
  defstruct [:payload]

  @type t :: %FacebookMessenger.Postback{
    payload: String.t
  }
end

defmodule FacebookMessenger.Messaging do
  @moduledoc """
  Facebook messaging structure, contains the sender, recepient and message info
  """
  @derive [Poison.Encoder]
  defstruct [:sender, :recipient, :timestamp, :message, :optin, :postback]

  @type t :: %FacebookMessenger.Messaging{
    sender: FacebookMessenger.User.t,
    recipient: FacebookMessenger.User.t,
    timestamp: integer,
    message: FacebookMessenger.Message.t,
    optin: FacebookMessenger.Optin.t,
    postback: FacebookMessenger.Postback.t
  }
end

defmodule FacebookMessenger.Entry do
  @moduledoc """
  Facebook entry structure
  """
  @derive [Poison.Encoder]
  defstruct [:id, :time, :messaging]

  @type t :: %FacebookMessenger.Entry{
    id: String.t,
    messaging: FacebookMessenger.Messaging.t,
    time: integer
  }
end

defmodule FacebookMessenger.Response do
  @moduledoc """
  Facebook messenger response structure
  """
  @derive [Poison.Encoder]
  defstruct [:object, :entry]

  @doc """
  Decode a map into a `FacebookMessenger.Response`
  """
  @spec parse(map) :: FacebookMessenger.Response.t
  def parse(param) when is_map(param) do
    Poison.Decode.decode(param, as: decoding_map)
  end

  @doc """
  Decode a string into a `FacebookMessenger.Response`
  """
  @spec parse(String.t) :: FacebookMessenger.Response.t
  def parse(param) when is_binary(param) do
    Poison.decode!(param, as: decoding_map)
  end

  @doc """
  Retrun an list of messages from a `FacebookMessenger.Response`
  """
  @spec messages(FacebookMessenger.Response) :: [FacebookMessenger.Messaging.t]
  def messages(%{entry: entries}) do
    Enum.flat_map(entries, &Map.get(&1, :messaging))
  end

  @doc """
  Retrun an list of messages from a `FacebookMessenger.Response`
  """
  @spec messages(FacebookMessenger.Response) :: [FacebookMessenger.Messaging.t]
  def messages(entries) when is_list(entries) do
    Enum.flat_map(entries, &Map.get(&1, :messaging))
  end

  @doc """
  Retrun an list of message texts from a `FacebookMessenger.Response`
  """
  @spec message_texts(FacebookMessenger.Response) :: [String.t]
  def message_texts(%{entry: entries}) do
    messages(entries)
    |> Enum.map(&(&1 |> Map.get(:message) |> Map.get(:text)))
  end

  @doc """
  Return a list of attachments from a `FacebookMessenger.Response`
  """
  @spec message_attachments(FacebookMessenger.Response) :: [FacebookMessenger.Attachment.t]
  def message_attachments(%{entry: entries}) do
    messages(entries)
    |> Enum.map(&(&1 |> Map.get(:message)))
    |> Enum.flat_map(&Map.get(&1, :attachments))
  end

  @doc """
  Retrun an list of message sender Ids from a `FacebookMessenger.Response`
  """
  @spec message_senders(FacebookMessenger.Response) :: [String.t]
  def message_senders(%{entry: entries}) do
    messages(entries)
    |> Enum.map(&(&1 |> Map.get(:sender) |> Map.get(:id)))
  end

  @doc """
  Retrun an list of optins from a `FacebookMessenger.Response`
  """
  @spec message_optins(FacebookMessenger.Response) :: [String.t]
  def message_optins(%{entry: entries}) do
    messages(entries)
    |> Enum.map(&(&1 |> Map.get(:optin) |> Map.get(:ref)))
  end


  defp decoding_map do
    messaging_parser =
    %FacebookMessenger.Messaging{
      "sender": %FacebookMessenger.User{},
      "recipient": %FacebookMessenger.User{},
      "message": %FacebookMessenger.Message{
        "attachments": [%FacebookMessenger.Attachment{}]
      },
      "optin": %FacebookMessenger.Optin{},
      "postback": %FacebookMessenger.Postback{}
    }

    %FacebookMessenger.Response{
      "entry": [%FacebookMessenger.Entry{
        "messaging": [messaging_parser]
      }]
    }
  end

  @type t :: %FacebookMessenger.Response{
    object: String.t,
    entry: FacebookMessenger.Entry.t
  }
end
