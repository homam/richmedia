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
    # gx, Mobitrans
    | 1025 => "/?impressionId=#{impressionId}"
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