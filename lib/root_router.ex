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
  @corpid "ding3397a1df06ad2dc935c2f4657eb6378f"
  @corpsecret "4ELgykVzy_Y0Q6SpQD05b2l8cgCMP59NJJvcHeDx8wPDNK8V9KtGc8p3eKcMi2JV"

  plug :match
  plug Plug.Logger
  plug Plug.Parsers, 
    parsers: [ :urlencoded, Plug.Parsers.Jiffy, Plug.Parsers.MULTIPART ],
    length: 900_000_000
  plug :dispatch

  get "/" do
    conn = fetch_query_params(conn)
    %{ "code" => tmp_auth_code, "state" => state } = conn.params
    IO.puts "code #{tmp_auth_code}, state #{state}\n"
     %{"unionid" => unionid } = handle_login(tmp_auth_code)
    # get_user_info(unionid)
    get_depart_info()

    send_resp(conn, 200, "Login Succeed")
  end

  def get_depart_info() do
    access_token = get_corp_session()
    IO.puts "获取 部门列表"
    %{ "department" => department } = 
      "https://oapi.dingtalk.com/department/list?access_token="<>access_token
      |> HTTPotion.get!()
      |> handle_response
    root_depart = Enum.find(department, fn(x) -> x["id"] == 1 end)
    get_depart_list(department, [root_depart], %{})
  end

  def get_depart_list(department, level_depart, res) do
    IO.puts "**********level_depart**********"
    IO.inspect level_depart
    for x <- level_depart do
      IO.puts "---------------\n"
      sub_depart = get_sub_depart_list(department, x["id"], res)
      res = Map.put(res, x["id"], sub_depart)
      # res = [sub_depart | res]
      get_depart_list(department, sub_depart, res)
    end
    IO.puts "-----------res ---------"
    IO.inspect res
  end

  def get_sub_depart_list(department, parent_id, res) do
    IO.inspect "Find parent_id #{parent_id}"
    Enum.filter(department, fn(x) ->  x["parentid"] == parent_id end)
  end

  def get_user_info(unionid) do
    access_token = get_corp_session()
    %{ "access_token" => access_token } = 
      "https://oapi.dingtalk.com/gettoken?corpid="<>@corpid<>"&corpsecret="<>@corpsecret
      |> HTTPotion.get!()
      |> handle_response

    IO.puts "获取userid"
    %{ "userid" => userid } = 
      "https://oapi.dingtalk.com/user/getUseridByUnionid?access_token="<>
    access_token <>"&unionid="<>unionid
      |> HTTPotion.get!()
      |> handle_response

     IO.puts "获取user 信息"
      "https://oapi.dingtalk.com/user/get?access_token="<>access_token <>"&userid="<>userid
      |> HTTPotion.get!()
      |> handle_response

  end

  def get_corp_session() do
    IO.puts "获取企业 access_token"
    %{ "access_token" => access_token } = 
      "https://oapi.dingtalk.com/gettoken?corpid="<>@corpid<>"&corpsecret="<>@corpsecret
      |> HTTPotion.get!()
      |> handle_response
    access_token
  end

  def handle_login(tmp_auth_code) do
    IO.puts "获取第三方登录的 access_token"
    %{ "access_token" => access_token } = 
      "https://oapi.dingtalk.com/sns/gettoken?appid="<>@appid<>"&appsecret="<>@appsecret
      |> HTTPotion.get!()
      |> handle_response

    IO.puts "获取persistent_code"
    %{ "persistent_code" => persistent_code, "openid" => openid }  =
          "https://oapi.dingtalk.com/sns/get_persistent_code?access_token=" <> access_token
          |> HTTPotion.post!([
            body: '{"tmp_auth_code": "#{tmp_auth_code}"}',
            headers: ["Content-Type": "application/json"] ])
          |> handle_response

    IO.puts "获取sns_token"
    %{"sns_token" => sns_token} =  
                 "https://oapi.dingtalk.com/sns/get_sns_token?access_token=" <> access_token
                 |> HTTPotion.post!([
                   body: '{"persistent_code": "#{persistent_code}", "openid": "#{openid}"}',
                   headers: ["Content-Type": "application/json"]])
                 |> handle_response

    IO.puts "获取user_info"
    {:ok, user_info} = "https://oapi.dingtalk.com/sns/getuserinfo?sns_token=" <> sns_token
                 |> HTTPotion.get!()
                 |> handle_response
                 |> Map.fetch("user_info")
    user_info
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
