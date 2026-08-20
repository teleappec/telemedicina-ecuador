const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());

// Conexión a la Base de Datos SQLite
const db = new sqlite3.Database('./telemedicina.db', (err) => {
  if (err) {
    console.error('Error al conectar BD:', err.message);
  } else {
    console.log('Conectado a la base de datos SQLite.');
  }
});

// Inicialización de Tablas
db.serialize(() => {
  // Tabla Profesionales
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

  // Tabla Citas Médicas
  db.run(`
    CREATE TABLE IF NOT EXISTS citas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      paciente TEXT,
      cedula_paciente TEXT,
      fecha TEXT,
      hora TEXT,
      especialidad TEXT,
      motivo TEXT,
      estado TEXT DEFAULT 'Pendiente'
    )
  `);

  // Tabla Triaje y Atenciones de Enfermería
  db.run(`
    CREATE TABLE IF NOT EXISTS atenciones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      paciente TEXT,
      cedula_paciente TEXT,
      presion_arterial TEXT,
      frecuencia_cardiaca TEXT,
      temperatura TEXT,
      saturacion_oxigeno TEXT,
      clasificacion TEXT,
      observaciones TEXT,
      fecha TEXT
    )
  `);

  // Tabla Brigadas Médicas y GPS
  db.run(`
    CREATE TABLE IF NOT EXISTS brigadas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre_brigada TEXT,
      lugar TEXT,
      latitud REAL,
      longitud REAL,
      fecha TEXT,
      observaciones TEXT,
      estado TEXT DEFAULT 'Activa'
    )
  `);
});

// Ruta Raíz
app.get('/', (req, res) => {
  res.send('API Telemedicina Ecuador corriendo correctamente.');
});

// POST /api/login - Permite ingresar con Cédula o Correo
app.post('/api/login', (req, res) => {
  const { identificador, password, rol } = req.body;

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

// GET /api/profesionales - Listar profesionales
app.get('/api/profesionales', (req, res) => {
  const sql = `SELECT id, nombre, cedula, correo, rol, senescyt FROM profesionales`;
  db.all(sql, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ exito: false, mensaje: err.message });
    }
    res.status(200).json({ exito: true, profesionales: rows });
  });
});

// GET /api/citas - Listar citas
app.get('/api/citas', (req, res) => {
  const sql = `SELECT * FROM citas ORDER BY id DESC`;
  db.all(sql, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ exito: false, mensaje: 'Error al consultar citas.' });
    }
    res.status(200).json({ exito: true, citas: rows });
  });
});

// POST /api/citas - Agendar nueva cita
app.post('/api/citas', (req, res) => {
  const { paciente, cedula_paciente, fecha, hora, especialidad, motivo } = req.body;

  if (!paciente || !fecha || !hora) {
    return res.status(400).json({
      exito: false,
      mensaje: 'Paciente, fecha y hora son obligatorios.',
    });
  }

  const sql = `
    INSERT INTO citas (paciente, cedula_paciente, fecha, hora, especialidad, motivo)
    VALUES (?, ?, ?, ?, ?, ?)
  `;

  db.run(
    sql,
    [
      paciente,
      cedula_paciente || '',
      fecha,
      hora,
      especialidad || 'Medicina General',
      motivo || 'Consulta Médica General',
    ],
    function (err) {
      if (err) {
        return res.status(500).json({
          exito: false,
          mensaje: 'Error en la base de datos al agendar cita.',
        });
      }
      res.status(201).json({
        exito: true,
        mensaje: 'Cita agendada correctamente',
        id: this.lastID,
      });
    }
  );
});

// GET /api/atenciones - Obtener fichas de triaje
app.get('/api/atenciones', (req, res) => {
  const sql = `SELECT * FROM atenciones ORDER BY id DESC`;
  db.all(sql, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ exito: false, mensaje: 'Error al consultar registros de triaje.' });
    }
    res.status(200).json({ exito: true, atenciones: rows });
  });
});

// POST /api/atenciones - Registrar nueva ficha de triaje
app.post('/api/atenciones', (req, res) => {
  const {
    paciente,
    cedula_paciente,
    presion_arterial,
    frecuencia_cardiaca,
    temperatura,
    saturacion_oxigeno,
    clasificacion,
    observaciones
  } = req.body;

  if (!paciente || !clasificacion) {
    return res.status(400).json({
      exito: false,
      mensaje: 'El paciente y la clasificación son obligatorios.',
    });
  }

  const fechaHoy = new Date().toISOString().split('T')[0];

  const sql = `
    INSERT INTO atenciones 
    (paciente, cedula_paciente, presion_arterial, frecuencia_cardiaca, temperatura, saturacion_oxigeno, clasificacion, observaciones, fecha)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;

  db.run(
    sql,
    [
      paciente,
      cedula_paciente || '',
      presion_arterial || '120/80',
      frecuencia_cardiaca || '75 bpm',
      temperatura || '36.5 °C',
      saturacion_oxigeno || '98%',
      clasificacion,
      observaciones || '',
      fechaHoy,
    ],
    function (err) {
      if (err) {
        return res.status(500).json({
          exito: false,
          mensaje: 'Error al guardar la ficha de triaje en la BD.',
        });
      }
      res.status(201).json({
        exito: true,
        mensaje: 'Triaje registrado correctamente',
        id: this.lastID,
      });
    }
  );
});

// GET /api/brigadas - Listar brigadas médicas
app.get('/api/brigadas', (req, res) => {
  const sql = `SELECT * FROM brigadas ORDER BY id DESC`;
  db.all(sql, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ exito: false, mensaje: 'Error al consultar brigadas.' });
    }
    res.status(200).json({ exito: true, brigadas: rows });
  });
});

// POST /api/brigadas - Registrar nueva brigada médica con GPS
app.post('/api/brigadas', (req, res) => {
  const { nombre_brigada, lugar, latitud, longitud, fecha, observaciones } = req.body;

  if (!nombre_brigada || !lugar || !fecha) {
    return res.status(400).json({
      exito: false,
      mensaje: 'El nombre, lugar y fecha son obligatorios.',
    });
  }

  const sql = `
    INSERT INTO brigadas (nombre_brigada, lugar, latitud, longitud, fecha, observaciones)
    VALUES (?, ?, ?, ?, ?, ?)
  `;

  db.run(
    sql,
    [
      nombre_brigada,
      lugar,
      latitud || -0.1807,
      longitud || -78.4678,
      fecha,
      observaciones || '',
    ],
    function (err) {
      if (err) {
        return res.status(500).json({
          exito: false,
          mensaje: 'Error al registrar la brigada en la base de datos.',
        });
      }
      res.status(201).json({
        exito: true,
        mensaje: 'Brigada agendada exitosamente',
        id: this.lastID,
      });
    }
  );
});

// Arrancar Servidor
app.listen(PORT, () => {
  console.log(`Servidor Central TeleMedicina corriendo en el puerto ${PORT}`);
});