defmodule Elixirding.RootRouter do
  @moduledoc """
  根路由
  """
  use Plug.Router
  require Plug.Logger
  use Plug.Debugger
  import Plug.Conn

  plug :match
  plug Plug.Logger
  plug Plug.Parsers, 
    parsers: [ :urlencoded, Plug.Parsers.Jiffy, Plug.Parsers.MULTIPART ],
    length: 900_000_000
  plug :dispatch

  get "/" do
    # appid = "dingoaxmlpncfavddw1fok"
    # appsecret = "a0VlZMUpiIC4NnpIJ7FqF5QpxnnKq96Y4KMxUPJtRtbDWQLXrynziwbcJ-93dO8t"

    {:ok, access_token} = 
      "https://oapi.dingtalk.com/sns/gettoken?appid=dingoaxmlpncfavddw1fok&appsecret=a0VlZMUpiIC4NnpIJ7FqF5QpxnnKq96Y4KMxUPJtRtbDWQLXrynziwbcJ-93dO8t"
      |> HTTPotion.get!()
      |> handle_response
      |> Map.fetch("access_token")
    IO.inspect "access_token #{access_token}"

    conn = fetch_query_params(conn)
    %{ "code" => tmp_auth_code, "state" => state } = conn.params
    IO.puts "code #{tmp_auth_code}, state #{state}"

    IO.puts "{\"tmp_auth_code\": \"#{tmp_auth_code}\"}"
    res = 
      "https://oapi.dingtalk.com/sns/get_persistent_code?access_token=" <> access_token
      |> HTTPotion.post!([body: '{"tmp_auth_code": "#{tmp_auth_code}"}', headers: ["Content-Type": "application/json"]])
      |> handle_response


    {:ok, persistent_code}  = Map.fetch(res, "persistent_code")
    {:ok, openid}  = Map.fetch(res, "openid")
    IO.inspect "persistent_code #{persistent_code}, openid #{openid}"

    {:ok, sns_token} =  "https://oapi.dingtalk.com/sns/get_sns_token?access_token=" <> access_token
                 |> HTTPotion.post!([body: '{"persistent_code": "#{persistent_code}", "openid": "#{openid}"}', headers: ["Content-Type": "application/json"]])
                 |> handle_response
                 |>  Map.fetch("sns_token")
    IO.inspect "sns_token #{sns_token}"

    user_info = "https://oapi.dingtalk.com/sns/getuserinfo?sns_token=" <> sns_token
                 |> HTTPotion.get!()
                 |> handle_response
    IO.inspect user_info

    send_resp(conn, 200, "Finish")
  end

  def handle_response(%HTTPotion.Response{status_code: 200, headers: _, body: body}) do
    IO.inspect(JSON.decode!(body))
    JSON.decode!(body)
  end
end
