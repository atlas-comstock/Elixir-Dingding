defmodule Elixirding.RootRouter do
  @moduledoc """
  根路由
  """
  use Plug.Router
  require Plug.Logger
  use Plug.Debugger
  import Plug.Conn
  @appid "dingoaxmlpncfavddw1fok"
  @appsecret "a0VlZMUpiIC4NnpIJ7FqF5QpxnnKq96Y4KMxUPJtRtbDWQLXrynziwbcJ-93dO8t"

  plug :match
  plug Plug.Logger
  plug Plug.Parsers, 
    parsers: [ :urlencoded, Plug.Parsers.Jiffy, Plug.Parsers.MULTIPART ],
    length: 900_000_000
  plug :dispatch

  get "/" do

    %{ "access_token" => access_token } = 
      "https://oapi.dingtalk.com/sns/gettoken?appid="<>@appid<>"&appsecret="<>@appsecret
      |> HTTPotion.get!()
      |> handle_response

    conn = fetch_query_params(conn)
    %{ "code" => tmp_auth_code, "state" => state } = conn.params
    IO.puts "code #{tmp_auth_code}, state #{state}\n"

    %{ "persistent_code" => persistent_code, "openid" => openid }  =
          "https://oapi.dingtalk.com/sns/get_persistent_code?access_token=" <> access_token
          |> HTTPotion.post!([
            body: '{"tmp_auth_code": "#{tmp_auth_code}"}',
            headers: ["Content-Type": "application/json"] ])
          |> handle_response

    %{"sns_token" => sns_token} =  
                 "https://oapi.dingtalk.com/sns/get_sns_token?access_token=" <> access_token
                 |> HTTPotion.post!([
                   body: '{"persistent_code": "#{persistent_code}", "openid": "#{openid}"}',
                   headers: ["Content-Type": "application/json"]])
                 |> handle_response

    user_info = "https://oapi.dingtalk.com/sns/getuserinfo?sns_token=" <> sns_token
                 |> HTTPotion.get!()
                 |> handle_response

    send_resp(conn, 200, "Login Succeed")
  end

  def handle_response(%HTTPotion.Response{status_code: 200, headers: _, body: body}) do
    res = JSON.decode!(body)
    IO.inspect res
    %{"errcode" => errcode, "errmsg" => errmsg } = res

    if errcode != 0 do
      IO.inspect("error: #{errmsg}, errcode: #{errcode}")
    else
      res
    end
  end

  def handle_response(_) do
    IO.puts "http error"
  end


  get "/favicon.ico" do
    send_resp(conn, 200, "nope")
  end
end
