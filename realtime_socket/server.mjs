import { createServer } from 'http';
import { Server } from 'socket.io';

const port = Number(process.env.PORT || 3001);

const httpServer = createServer();
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

io.on('connection', (socket) => {
  socket.on('join_room', (payload = {}) => {
    const room = String(payload.room || 'default-room');
    const userId = String(payload.userId || socket.id);
    socket.data.userId = userId;
    socket.join(room);
    io.to(room).emit('private_message', {
      from: 'system',
      to: userId,
      body: `${userId} joined ${room}`,
      timestamp: new Date().toISOString(),
    });
  });

  socket.on('private_message', (payload = {}) => {
    const room = String(payload.room || 'default-room');
    io.to(room).emit('private_message', {
      from: String(payload.from || socket.data.userId || socket.id),
      to: String(payload.to || ''),
      body: String(payload.body || ''),
      timestamp: payload.timestamp || new Date().toISOString(),
    });
  });

  socket.on('presence_ping', (payload = {}) => {
    socket.emit('presence_pong', {
      userId: String(payload.userId || socket.data.userId || socket.id),
      timestamp: new Date().toISOString(),
    });
  });
});

httpServer.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(
      `Port ${port} is already in use. Either stop the other process or run:\n` +
        `  PORT=3002 npm start\n` +
        `On macOS/Linux you can free the port with:\n` +
        `  kill $(lsof -t -iTCP:${port} -sTCP:LISTEN)`,
    );
  } else {
    console.error(err);
  }
  process.exit(1);
});

httpServer.listen(port, () => {
  console.log(`Realtime socket server listening on http://localhost:${port}`);
});
