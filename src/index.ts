import ws from 'ws';

const wss = new ws.Server({
    port: 3333
});

console.log('starting');

wss.on('connection', function connection(ws) {
    ws.on('message', function incoming(message) {
      console.log('received: %s', message);
    });
  
    ws.send({
        ts: Date.now(),
        target: "No",
        req: "2 + 2"
    });
});