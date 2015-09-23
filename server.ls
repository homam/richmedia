{http-port, converted-log} = require \./config
express = require \express
app = express!
fs = require \fs

app.get '/api/converted', (req, res) ->
    now = new Date!.valueOf!
    console.log now, req.url, req.path, req.query, req.headers
    err <- fs.append-file converted-log, "#{JSON.stringify {req.url, req.path, req.query, req.headers}}\n"
    if !!err 
        console.error err
        res.status 500
        res.end 'error'
        return

    res.end ''

app.listen http-port

console.log "listening for connections on port: #{http-port}"