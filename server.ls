{http-port, converted-log} = require \./config
express = require \express
app = express!
    ..disable 'x-powered-by'
fs = require \fs
base62 = require \base62

get-unique-id = do ->
    epoch = new Date 2015, 8, 1 .value-of!
    (now) ->
        ( (now - epoch) * 1024) + (Math.round <| Math.random! * 1024)

app.get '/api/converted', (req, res) ->
    now = new Date!.valueOf!
    console.log now, "GET", req.url, req.path, req.query, req.headers
    err <- fs.append-file converted-log, "#{JSON.stringify {req.url, req.path, req.query, req.headers}}\n"
    if !!err 
        console.error err
        res.status 500
        res.end 'error'
        return

    res.end ''

campaigns-map = (campaignId, impressionId) ->
    match campaignId
    # AE, Mobitrans
    # gx
    | 1025 => "http://pages.mobileacademy.com/om/_/ma/LearnAnyTimeAnyWhere/531/17784/?impressionid=#{impressionId}"
    # IT, Mobitrans
    # gy
    | 1026 => "http://start.mobileacademy.com/?campaignid=17821&forcedPage=484&v=529&impressionid=#{impressionId}"
    # gz
    | 1027 => "http://start.mobileacademy.com/?campaignid=17821&forcedPage=656&v=526&impressionid=#{impressionId}"
    # QA, Mobitrans
    # gA
    | 1028 => "http://wap.mozook.com/qatar/?campaignid=17822&forcedpage=485&v=585&impressionid=#{impressionId}"
    # gB
    | 1029 => "http://wap.mozook.com/qatar/?campaignid=17822&forcedpage=727&v=545&impressionid=#{impressionId}"
    # gC
    | 1030 => "http://wap.mozook.com/qatar/?campaignid=17822&forcedpage=757&v=549&impressionid=#{impressionId}"
    # OM, Mobitrans
    # gD
    | 1031 => "http://start.mobileacademy.com?campaignid=17823&forcedpage=609&v=542&impressionid=#{impressionId}"
    # gE
    | 1032 => "http://start.mobileacademy.com?campaignid=17823&forcedpage=484&v=539&impressionid=#{impressionId}"
    # gF
    | 1033 => "http://start.mobileacademy.com?campaignid=17823&forcedpage=458&v=640&impressionid=#{impressionId}"

    | _ => throw "Invalid Campaign Id"

app.get '/api/impression-and-click/:campaignId', (req, res) ->
    now = new Date!.valueOf!
    console.log now, "GET", req.url, req.path, req.query, req.headers

    impressionId = get-unique-id now
    campaignId = base62.decode req.params.campaignId

    try
        url = campaigns-map campaignId, (base62.encode impressionId)
        console.log now, "impression-and-click", req.params.campaignId, campaignId, impressionId, url
        res.redirect url
    catch err
        console.error err
        res.status 500
        res.end err.toString!





app.listen http-port

console.log "listening for connections on port: #{http-port}"