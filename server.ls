{http-port, converted-log, impression-and-click-log-bson, converted-log-bson} = require \./config
express = require \express
app = express!
    ..disable 'x-powered-by'
fs = require \fs
base62 = require \base62

# Referrer: wap p478, 1890
# ParnterId: 531



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



app.use "/templates", express.static "#__dirname/html-templates"

serve-tag = (res, {visit-url, sub-url}) ->
    res.end """<html><head>
    <meta name="referrer" content="no-referrer" />
    </head>
    <body>
    <iframe width="100%" height="100%" border="0" style="position: fixed; top:0; left: 0; right: 0; bottom: 0" src="/templates/iredir.html\##{visit-url}"></iframe>
    <iframe width="100%" height="100%" border="0" style="position: fixed; top:0; left: 0; right: 0; bottom: 0" src="/templates/redir.html\##{sub-url}"></iframe>
    </body>
    </html>
    """

# path: http://wap.mozook.com/qatar/
to-sub-url = (path, country, oc, superCampaignId, campaignId, serviceId, refId, forcedPage, v, modified-impressionId) ->
    "#{path}?campaignid=#{campaignId}&forcedpage=#{forcedPage}&v=#{v}&impressionid=#{modified-impressionId}&PageID=#{forcedPage}&RefID=#{refId}&SubMethod=DirectWAP&PageType=LandingPage&IsEmbeddedOcFlag=False&OC=#{oc}&SuperCampaignId=#{superCampaignID}&ServiceID=#{serviceId}&Country=#{country}&reqType=JumpSubmission&XMobiWAPBrowser=False&Choice=1"

campaigns-auto-map = (campaignId, base62CampaignId, impressionId) ->
    modified-impressionId = "#{base62CampaignId}-#{impressionId}"
    match campaignId
    # OM, Mobitrans
    # gD
    # http://localhost:8081/api/a/impression-and-click/gD
    | 1031 => 
        visit-url = "http://start.mobileacademy.com/?campaignid=17823&ref=p478&forcedpage=609&v=542&impressionid=#{modified-impressionId}"
        sub-url =   "http://start.mobileacademy.com/default.aspx?campaignid=17823&forcedpage=609&v=542&ref=p478&impressionid=#{modified-impressionId}&SubMethod=DirectWAP&PageType=LandingPage&IsEmbeddedOcFlag=False&OC=2&SuperCampaignID=911&RefID=1890&PageID=609&ServiceID=3100&Country=Oman&reqType=DirectWAPSubmission&XMobiWAPBrowser=False&Choice=1"
        if Math.random! > 0.3 
            sub-url = visit-url
        {
            visit-url
            sub-url
        }
    # Unknown campaign
    | 9841 => {
        visit-url: "http://start.mobileacademy.com/?campaignid=9841&ref=0&forcedpage=609&v=542"
        sub-url:   "http://start.mobileacademy.com/default.aspx?campaignid=9841&forcedpage=609&v=542&&SubMethod=DirectWAP&PageType=LandingPage&IsEmbeddedOcFlag=False&OC=2&SuperCampaignID=911&RefID=0&PageID=609&ServiceID=3100&Country=Oman&reqType=DirectWAPSubmission&XMobiWAPBrowser=False&Choice=1"
    }
    # QA
    # gB
    # http://localhost:8081/api/a/impression-and-click/gB
    | 1029 => 
        visit-url = "http://wap.mozook.com/qatar/?campaignid=17822&ref=p478&forcedpage=727&v=545&impressionid=#{modified-impressionId}"
        sub-url = "http://wap.mozook.com/qatar/?campaignid=17822&forcedpage=727&v=545&impressionid=#{modified-impressionId}&SubMethod=DirectWAP&PageType=LandingPage&IsEmbeddedOcFlag=False&OC=10&SuperCampaignID=192&RefID=1890&PageID=727&ServiceID=3100&Country=Qatar&reqType=DirectWAPSubmission&XMobiWAPBrowser=False&Choice=1"
        if Math.random! > 0.3 
            sub-url = visit-url
        {
            visit-url
            sub-url
        }
    # Unknown campaign
    # 2j9
    # http://localhost:8081/api/a/impression-and-click/2j9
    | 8875 => 
        {
            visit-url: "http://wap.mozook.com/qatar/?campaignid=8875"
            sub-url: "http://wap.mozook.com/qatar/?campaignid=8875&SubMethod=DirectWAP&PageType=LandingPage&IsEmbeddedOcFlag=False&OC=10&SuperCampaignID=192&RefID=0&PageID=727&ServiceID=3100&Country=Qatar&reqType=DirectWAPSubmission&XMobiWAPBrowser=False&Choice=1"
        }
    | _ => throw "Invalid Campaign Id"

campaigns-map = (campaignId, base62CampaignId, impressionId) ->
    modified-impressionId = "#{base62CampaignId}-#{impressionId}"
    match campaignId
    # AE, Mobitrans
    # gx
    | 1025 => "http://pages.mobileacademy.com/om/_/ma/LearnAnyTimeAnyWhere/531/17784/?impressionid=#{modified-impressionId}"
    # IT, Mobitrans
    # gy
    | 1026 => "http://start.mobileacademy.com/?campaignid=17821&ref=p478&forcedPage=484&v=529&impressionid=#{modified-impressionId}"
    # gz
    | 1027 => "http://start.mobileacademy.com/?campaignid=17821&ref=p478&forcedPage=656&v=526&impressionid=#{modified-impressionId}"
    # QA, Mobitrans
    # gA
    | 1028 => "http://wap.mozook.com/qatar/?campaignid=17822&ref=p478&forcedpage=485&v=585&impressionid=#{modified-impressionId}"
    # gB
    | 1029 => "http://wap.mozook.com/qatar/?campaignid=17822&ref=p478&forcedpage=727&v=545&impressionid=#{modified-impressionId}"
    # gC
    | 1030 => "http://wap.mozook.com/qatar/?campaignid=17822&ref=p478&forcedpage=757&v=549&impressionid=#{modified-impressionId}"
    # OM, Mobitrans
    # gD
    | 1031 => "http://start.mobileacademy.com?campaignid=17823&ref=p478&forcedpage=609&v=542&impressionid=#{modified-impressionId}"
    # gE
    | 1032 => "http://start.mobileacademy.com?campaignid=17823&ref=p478&forcedpage=484&v=539&impressionid=#{modified-impressionId}"
    # gF
    | 1033 => "http://start.mobileacademy.com?campaignid=17823&ref=p478&forcedpage=458&v=640&impressionid=#{modified-impressionId}"

    | _ => throw "Invalid Campaign Id"


app.get '/api/a/impression-and-click/:campaignId', (req, res) ->
    now = new Date!.valueOf!
    console.log now, "GET", req.url, req.path, req.query, req.headers

    campaignId = base62.decode req.params.campaignId
    impressionId = get-unique-id now
    base62ImpressionId = base62.encode impressionId

    try
        urls = campaigns-auto-map campaignId, req.params.campaignId, base62ImpressionId
        console.log now, "/a/impression-and-click", req.params.campaignId, campaignId, impressionId, urls.visit-url, urls.sub-url

        log-obj impression-and-click-log-bson, {
            time: new Date!.value-of!
            url: req.url
            redirect: urls.visit-url
            campaignId
            base62CampaignId: req.params.campaignId
            impressionId
            base62ImpressionId: base62ImpressionId
            headers: req.headers
            query: req.query
            ip: req.ip
            auto: true
        }

        serve-tag res, urls
    catch err
        console.error err
        res.status 500
        res.end err.toString!

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


app.listen http-port

console.log "listening for connections on port: #{http-port}"