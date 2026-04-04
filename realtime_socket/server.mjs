import { createServer } from 'http';
import { Server } from 'socket.io';

const port = Number(process.env.PORT || 3001);

const httpServer = createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ status: 'ok', activeUsers: activeUsers.size }));
});

const io = new Server(httpServer, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

// ── Active-user tracking ──────────────────────────────
// Map<socketId, { userId, displayName, joinedAt }>
const activeUsers = new Map();

function broadcastUserList() {
  const list = [...activeUsers.values()].map((u) => ({
    userId: u.userId,
    displayName: u.displayName,
  }));
  io.emit('user_list', { users: list, count: list.length });
}

// ── Connection handler ────────────────────────────────
io.on('connection', (socket) => {
  console.log(`+ socket connected: ${socket.id}`);

  // Client sends this right after connecting
  socket.on('register_user', (payload = {}) => {
    const userId = String(payload.userId || socket.id);
    const displayName = String(payload.displayName || 'Anonymous');

    activeUsers.set(socket.id, {
      userId,
      displayName,
      joinedAt: new Date().toISOString(),
    });

    console.log(`  registered: ${displayName} (${userId})`);
    broadcastUserList();

    // Send a system message so everyone sees who joined
    io.emit('receive_message', {
      id: `sys-${Date.now()}`,
      sender: '__system__',
      senderName: 'System',
      text: `${displayName} joined the chat`,
      timestamp: new Date().toISOString(),
    });
  });

  // Client sends a chat message
  socket.on('send_message', (payload = {}) => {
    const me = activeUsers.get(socket.id);
    const msg = {
      id: `${socket.id}-${Date.now()}`,
      sender: String(payload.sender || me?.userId || socket.id),
      senderName: String(payload.senderName || me?.displayName || 'Anonymous'),
      text: String(payload.text || ''),
      timestamp: payload.timestamp || new Date().toISOString(),
    };

    // Broadcast to ALL sockets including the sender
    io.emit('receive_message', msg);
  });

  // Typing indicator
  socket.on('typing', (payload = {}) => {
    socket.broadcast.emit('user_typing', {
      userId: payload.userId,
      displayName: payload.displayName,
    });
  });

  socket.on('stop_typing', () => {
    socket.broadcast.emit('user_stop_typing', {
      userId: activeUsers.get(socket.id)?.userId,
    });
  });

  // Disconnect
  socket.on('disconnect', (reason) => {
    const user = activeUsers.get(socket.id);
    if (user) {
      console.log(`- disconnected: ${user.displayName} (${reason})`);
      activeUsers.delete(socket.id);
      broadcastUserList();

      io.emit('receive_message', {
        id: `sys-${Date.now()}`,
        sender: '__system__',
        senderName: 'System',
        text: `${user.displayName} left the chat`,
        timestamp: new Date().toISOString(),
      });
    }
  });
});

// ── Start ─────────────────────────────────────────────
httpServer.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(
      `Port ${port} is already in use. Stop the other process or run:\n` +
        `  PORT=3002 npm start`
    );
  } else {
    console.error(err);
  }
  process.exit(1);
});

httpServer.listen(port, () => {
  console.log(`Creation realtime server listening on http://localhost:${port}`);
});
