defmodule FacebookMessenger.Message.Test do
  use ExUnit.Case

  test "it gets initialized from a string" do
    {:ok, file} = File.read("#{System.cwd}/test/fixtures/messenger_response.json")

    res = FacebookMessenger.Response.parse(file)
    assert is_list(res.entry) == true
    assert res.entry |> hd |> Map.get(:id) == "PAGE_ID"

    messaging = res.entry |> hd |> Map.get(:messaging)
    assert messaging |> is_list == true
    assert messaging |> hd |> Map.get(:sender) |> Map.get(:id) == "USER_ID"
    assert messaging |> hd |> Map.get(:recipient) |> Map.get(:id) == "PAGE_ID"

    message = messaging |> hd |> Map.get(:message)
    assert message.text == "hello 1"
  end

  test "it gets initialized from a json" do
    {:ok, file} = File.read("#{System.cwd}/test/fixtures/messenger_response.json")
    {:ok, json} = file |> Poison.decode

    res = FacebookMessenger.Response.parse(json)
    assert is_list(res.entry) == true
    assert res.entry |> hd |> Map.get(:id) == "PAGE_ID"

    messaging = res.entry |> hd |> Map.get(:messaging)
    assert messaging |> is_list == true
    assert messaging |> hd |> Map.get(:sender) |> Map.get(:id) == "USER_ID"
    assert messaging |> hd |> Map.get(:recipient) |> Map.get(:id) == "PAGE_ID"

    message = messaging |> hd |> Map.get(:message)
    assert message.text == "hello 1"
  end

  test "it gets the messages from the response" do
    {:ok, file} = File.read("#{System.cwd}/test/fixtures/messenger_response.json")
    res = FacebookMessenger.Response.parse(file)
    res = FacebookMessenger.Response.messages(res)
    assert res == [%FacebookMessenger.Messaging{message: %FacebookMessenger.Message{attachments: [%FacebookMessenger.Attachment{payload: nil, title: nil,
                type: nil, url: nil}], mid: "mid.1460245671959:dad2ec9421b03d6f78", seq: 216, text: "hello 1"},
             optin: %FacebookMessenger.Optin{ref: nil}, postback: %FacebookMessenger.Postback{payload: nil},
             recipient: %FacebookMessenger.User{id: "PAGE_ID"}, sender: %FacebookMessenger.User{id: "USER_ID"}, timestamp: 1460245672080},
            %FacebookMessenger.Messaging{message: %FacebookMessenger.Message{attachments: [%FacebookMessenger.Attachment{payload: nil, title: nil,
                type: nil, url: nil}], mid: "mid.1460245671959:dad2ec9421b03d6f78", seq: 216, text: "hello 2"},
             optin: %FacebookMessenger.Optin{ref: nil}, postback: %FacebookMessenger.Postback{payload: nil},
             recipient: %FacebookMessenger.User{id: "PAGE_ID"}, sender: %FacebookMessenger.User{id: "USER_ID"}, timestamp: 1460245672080},
            %FacebookMessenger.Messaging{message: %FacebookMessenger.Message{attachments: [%FacebookMessenger.Attachment{payload: nil, title: nil,
                type: nil, url: nil}], mid: nil, seq: nil, text: nil}, optin: %FacebookMessenger.Optin{ref: "PASS_THROUGH_PARAM"},
             postback: %FacebookMessenger.Postback{payload: nil}, recipient: %FacebookMessenger.User{id: "PAGE_ID"},
             sender: %FacebookMessenger.User{id: "USER_ID"}, timestamp: 1460245672080}]
  end

  test "it gets the message text from the response" do
    {:ok, file} = File.read("#{System.cwd}/test/fixtures/messenger_response.json")
    res = FacebookMessenger.Response.parse(file)
    res = FacebookMessenger.Response.message_texts(res)
    assert res == ["hello 1", "hello 2", nil]
  end

  test "it gets the message sender id" do
    {:ok, file} = File.read("#{System.cwd}/test/fixtures/messenger_response.json")
    res = FacebookMessenger.Response.parse(file)
    res = FacebookMessenger.Response.message_senders(res)
    assert res == ["USER_ID", "USER_ID", "USER_ID"]
  end

  test "it gets the optins" do
    {:ok, file} = File.read("#{System.cwd}/test/fixtures/messenger_response.json")
    res = FacebookMessenger.Response.parse(file)
    res = FacebookMessenger.Response.message_optins(res)
    assert res == [nil, nil, "PASS_THROUGH_PARAM"]
  end

  test "parses location attachment" do
    {:ok, file} = File.read("#{System.cwd}/test/fixtures/messenger_location.json")
    res = FacebookMessenger.Response.parse(file)
    attachments = FacebookMessenger.Response.message_attachments(res)
    assert [%FacebookMessenger.Attachment{payload: %{"coordinates" => %{"lat" => latitude, "long" => longitude}}} | _ ] = attachments
  end
end
