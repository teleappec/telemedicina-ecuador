const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Conexión SQLite
const db = new sqlite3.Database('./telemedicina.db', (err) => {
  if (err) {
    console.error('Error al conectar BD:', err.message);
  } else {
    console.log('Conectado a la base de datos SQLite.');
  }
});

// Crear tabla con campo 'correo'
db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS profesionales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT,
      cedula TEXT UNIQUE,
      correo TEXT UNIQUE,
      password TEXT,
      rol TEXT,
      senescyt TEXT
    )
  `);
});

app.get('/', (req, res) => {
  res.send('API Telemedicina Ecuador funcionando.');
});

// POST /api/login - Permite ingresar con Cédula o Correo
app.post('/api/login', (req, res) => {
  const { identificador, password, rol } = req.body; // identificador = cedula o correo

  if (!identificador || !password || !rol) {
    return res.status(400).json({
      exito: false,
      mensaje: 'Todos los campos son obligatorios.'
    });
  }

  const sql = `
    SELECT * FROM profesionales 
    WHERE (cedula = ? OR correo = ?) AND password = ? AND UPPER(rol) = UPPER(?)
  `;

  db.get(sql, [identificador, identificador, password, rol], (err, usuario) => {
    if (err) {
      console.error('Error BD:', err.message);
      return res.status(500).json({ exito: false, mensaje: 'Error interno del servidor.' });
    }

    if (usuario) {
      return res.status(200).json({
        exito: true,
        mensaje: 'Acceso autorizado',
        usuario: {
          id: usuario.id,
          nombre: usuario.nombre,
          cedula: usuario.cedula,
          correo: usuario.correo,
          rol: usuario.rol,
          senescyt: usuario.senescyt || '',
        },
      });
    } else {
      return res.status(401).json({
        exito: false,
        mensaje: 'Credenciales o rol incorrectos.',
      });
    }
  });
});

// POST /api/profesionales - Registro de nuevo profesional
app.post('/api/profesionales', (req, res) => {
  const { nombre, cedula, correo, password, rol, senescyt } = req.body;

  if (!nombre || !cedula || !correo || !password || !rol) {
    return res.status(400).json({
      exito: false,
      mensaje: 'Faltan campos requeridos para el registro.',
    });
  }

  const sql = `INSERT INTO profesionales (nombre, cedula, correo, password, rol, senescyt) VALUES (?, ?, ?, ?, ?, ?)`;

  db.run(sql, [nombre, cedula, correo, password, rol, senescyt || ''], function (err) {
    if (err) {
      if (err.message.includes('UNIQUE constraint failed')) {
        return res.status(400).json({
          exito: false,
          mensaje: 'La cédula o el correo ya se encuentran registrados.',
        });
      }
      console.error('Error insert:', err.message);
      return res.status(500).json({
        exito: false,
        mensaje: 'Error al registrar el profesional en la base de datos.',
      });
    }

    return res.status(201).json({
      exito: true,
      mensaje: 'Profesional registrado con éxito',
      id: this.lastID,
    });
  });
});

app.listen(PORT, () => {
  console.log(`Servidor en puerto ${PORT}`);
});