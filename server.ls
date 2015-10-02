{http-port, converted-log, impression-and-click-log-bson, converted-log-bson} = require \./config
express = require \express
app = express!
    ..disable 'x-powered-by'
fs = require \fs
base62 = require \base62


log = do ->
    streams = {}
    (file, message) -->
        if !streams[file]
            streams[file] = fs.createWriteStream file, {flags: \a}
        streams[file].write message + "\n"

log-obj = (file, message) -->
    log file, (JSON.stringify message)


get-unique-id = do ->
    epoch = new Date 2015, 8, 1 .value-of!
    (now) ->
        ( (now - epoch) * 1024) + (Math.round <| Math.random! * 1024)

app.get '/api/converted', (req, res) ->
    now = new Date!.valueOf!
    console.log now, "GET", req.url, req.path, req.query, req.headers

    [base62CampaignId, base62ImpressionId]:arr = (req.query.impId ? req.query.impid ? "").split \-
    if arr.length == 2
        campaignId = base62.decode base62CampaignId
        impressionId = base62.decode base62ImpressionId
    else
        impressionId = base62.decode campaignId

    log-obj converted-log-bson, {
        time: new Date!.value-of!
        url: req.url
        campaignId
        base62CampaignId
        impressionId
        base62ImpressionId
        headers: req.headers
        query: req.query
        ip: req.ip
    }

    # Obsolete \/
    err <- fs.append-file converted-log, "#{JSON.stringify {req.url, req.path, req.query, req.headers}}\n"
    if !!err 
        console.error err
        res.status 500
        res.end 'error'
        return
    # Obsolete /\

    res.end ''

campaigns-map = (campaignId, base62CampaignId, impressionId) ->
    match campaignId
    # AE, Mobitrans
    # gx
    | 1025 => "http://pages.mobileacademy.com/om/_/ma/LearnAnyTimeAnyWhere/531/17784/?impressionid=#{base62CampaignId}-#{impressionId}"
    # IT, Mobitrans
    # gy
    | 1026 => "http://start.mobileacademy.com/?campaignid=17821&forcedPage=484&v=529&impressionid=#{base62CampaignId}-#{impressionId}"
    # gz
    | 1027 => "http://start.mobileacademy.com/?campaignid=17821&forcedPage=656&v=526&impressionid=#{base62CampaignId}-#{impressionId}"
    # QA, Mobitrans
    # gA
    | 1028 => "http://wap.mozook.com/qatar/?campaignid=17822&forcedpage=485&v=585&impressionid=#{base62CampaignId}-#{impressionId}"
    # gB
    | 1029 => "http://wap.mozook.com/qatar/?campaignid=17822&forcedpage=727&v=545&impressionid=#{base62CampaignId}-#{impressionId}"
    # gC
    | 1030 => "http://wap.mozook.com/qatar/?campaignid=17822&forcedpage=757&v=549&impressionid=#{base62CampaignId}-#{impressionId}"
    # OM, Mobitrans
    # gD
    | 1031 => "http://start.mobileacademy.com?campaignid=17823&forcedpage=609&v=542&impressionid=#{base62CampaignId}-#{impressionId}"
    # gE
    | 1032 => "http://start.mobileacademy.com?campaignid=17823&forcedpage=484&v=539&impressionid=#{base62CampaignId}-#{impressionId}"
    # gF
    | 1033 => "http://start.mobileacademy.com?campaignid=17823&forcedpage=458&v=640&impressionid=#{base62CampaignId}-#{impressionId}"

    | _ => throw "Invalid Campaign Id"

app.get '/api/impression-and-click/:campaignId', (req, res) ->
    now = new Date!.valueOf!
    console.log now, "GET", req.url, req.path, req.query, req.headers

    campaignId = base62.decode req.params.campaignId
    impressionId = get-unique-id now
    base62ImpressionId = base62.encode impressionId

    try
        url = campaigns-map campaignId, req.params.campaignId, base62ImpressionId
        console.log now, "impression-and-click", req.params.campaignId, campaignId, impressionId, url

        log-obj impression-and-click-log-bson, {
            time: new Date!.value-of!
            url: req.url
            redirect: url
            campaignId
            base62CampaignId: req.params.campaignId
            impressionId
            base62ImpressionId: base62ImpressionId
            headers: req.headers
            query: req.query
            ip: req.ip
        }

        res.redirect url
    catch err
        console.error err
        res.status 500
        res.end err.toString!





app.listen http-port

console.log "listening for connections on port: #{http-port}"