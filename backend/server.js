const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();

const app = express();
// Render asigna dinámicamente el puerto mediante la variable de entorno PORT
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());

// Conexión a la base de datos SQLite
const db = new sqlite3.Database('./telemedicina.db', (err) => {
  if (err) {
    console.error('Error al conectar a la base de datos:', err.message);
  } else {
    console.log('Conectado a la base de datos SQLite.');
  }
});

// Inicialización de la base de datos (Creación de tablas si no existen)
db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS profesionales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT,
      cedula TEXT UNIQUE,
      password TEXT,
      rol TEXT,
      senescyt TEXT
    )
  `);
});

// Ruta raíz de verificación
app.get('/', (req, res) => {
  res.send('Servidor Central de Telemedicina Ecuador corriendo correctamente.');
});

// POST /api/login - Endpoint para autenticar usuarios
app.post('/api/login', (req, res) => {
  const { cedula, password, rol } = req.body;

  if (!cedula || !password || !rol) {
    return res.status(400).json({
      exito: false,
      mensaje: 'Todos los campos son obligatorios (cédula, contraseña y rol).'
    });
  }

  const sql = `SELECT * FROM profesionales WHERE cedula = ? AND password = ? AND UPPER(rol) = UPPER(?)`;

  db.get(sql, [cedula, password, rol], (err, usuario) => {
    if (err) {
      console.error('Error al consultar BD:', err.message);
      return res.status(500).json({
        exito: false,
        mensaje: 'Error interno del servidor al consultar credenciales'
      });
    }

    if (usuario) {
      return res.status(200).json({
        exito: true,
        mensaje: 'Acceso autorizado',
        usuario: {
          id: usuario.id,
          nombre: usuario.nombre,
          cedula: usuario.cedula,
          rol: usuario.rol,
          senescyt: usuario.senescyt || '',
        },
      });
    } else {
      return res.status(401).json({
        exito: false,
        mensaje: 'Cédula, contraseña o rol incorrectos',
      });
    }
  });
});

// POST /api/profesionales - Endpoint para registrar nuevo profesional
app.post('/api/profesionales', (req, res) => {
  const { nombre, cedula, password, rol, senescyt } = req.body;

  if (!cedula || !password || !rol) {
    return res.status(400).json({
      exito: false,
      mensaje: 'Cédula, contraseña y rol son obligatorios',
    });
  }

  const sql = `INSERT INTO profesionales (nombre, cedula, password, rol, senescyt) VALUES (?, ?, ?, ?, ?)`;

  db.run(sql, [nombre || '', cedula, password, rol, senescyt || ''], function (err) {
    if (err) {
      if (err.message.includes('UNIQUE constraint failed')) {
        return res.status(400).json({
          exito: false,
          mensaje: 'El usuario con esta cédula ya se encuentra registrado',
        });
      }
      console.error('Error al insertar profesional:', err.message);
      return res.status(500).json({
        exito: false,
        mensaje: 'Error en la base de datos al registrar usuario',
      });
    }

    return res.status(201).json({
      exito: true,
      mensaje: 'Profesional registrado exitosamente',
      id: this.lastID,
    });
  });
});

// GET /api/profesionales - Listar profesionales registrados
app.get('/api/profesionales', (req, res) => {
  const sql = `SELECT id, nombre, cedula, rol, senescyt FROM profesionales`;
  db.all(sql, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ exito: false, mensaje: err.message });
    }
    res.status(200).json({ exito: true, profesionales: rows });
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`Servidor Central TeleMedicina corriendo en el puerto ${PORT}`);
});