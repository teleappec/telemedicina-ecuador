const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());

// Configuración de la conexión PostgreSQL
const isProduction = process.env.DATABASE_URL ? true : false;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/telemedicina',
  ssl: isProduction ? { rejectUnauthorized: false } : false,
});

// Inicialización de Tablas en PostgreSQL
const initDB = async () => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS profesionales (
        id SERIAL PRIMARY KEY,
        nombre TEXT,
        cedula TEXT UNIQUE,
        correo TEXT UNIQUE,
        password TEXT,
        rol TEXT,
        senescyt TEXT
      );

      CREATE TABLE IF NOT EXISTS citas (
        id SERIAL PRIMARY KEY,
        paciente TEXT,
        cedula_paciente TEXT,
        fecha TEXT,
        hora TEXT,
        especialidad TEXT,
        motivo TEXT,
        estado TEXT DEFAULT 'Pendiente'
      );

      CREATE TABLE IF NOT EXISTS atenciones (
        id SERIAL PRIMARY KEY,
        paciente TEXT,
        cedula_paciente TEXT,
        presion_arterial TEXT,
        frecuencia_cardiaca TEXT,
        temperatura TEXT,
        saturacion_oxigeno TEXT,
        clasificacion TEXT,
        observaciones TEXT,
        fecha TEXT
      );

      CREATE TABLE IF NOT EXISTS brigadas (
        id SERIAL PRIMARY KEY,
        nombre_brigada TEXT,
        lugar TEXT,
        latitud REAL,
        longitud REAL,
        fecha TEXT,
        observaciones TEXT,
        estado TEXT DEFAULT 'Activa'
      );
    `);
    console.log('Tablas inicializadas correctamente en PostgreSQL.');
  } catch (err) {
    console.error('Error al inicializar PostgreSQL:', err.message);
  }
};

initDB();

// Ruta Raíz
app.get('/', (req, res) => {
  res.send('API Telemedicina Ecuador con PostgreSQL corriendo correctamente.');
});

// POST /api/login
app.post('/api/login', async (req, res) => {
  const { identificador, password, rol } = req.body;

  if (!identificador || !password || !rol) {
    return res.status(400).json({
      exito: false,
      mensaje: 'Todos los campos son obligatorios.',
    });
  }

  try {
    const sql = `
      SELECT * FROM profesionales 
      WHERE (cedula = $1 OR correo = $2) AND password = $3 AND UPPER(rol) = UPPER($4)
    `;
    const resultado = await pool.query(sql, [identificador, identificador, password, rol]);

    if (resultado.rows.length > 0) {
      const usuario = resultado.rows[0];
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
  } catch (err) {
    console.error('Error BD:', err.message);
    return res.status(500).json({ exito: false, mensaje: 'Error interno del servidor.' });
  }
});

// POST /api/profesionales - Registro
app.post('/api/profesionales', async (req, res) => {
  const { nombre, cedula, correo, password, rol, senescyt } = req.body;

  if (!nombre || !cedula || !correo || !password || !rol) {
    return res.status(400).json({
      exito: false,
      mensaje: 'Faltan campos requeridos para el registro.',
    });
  }

  try {
    const sql = `
      INSERT INTO profesionales (nombre, cedula, correo, password, rol, senescyt) 
      VALUES ($1, $2, $3, $4, $5, $6) RETURNING id
    `;
    const resultado = await pool.query(sql, [
      nombre,
      cedula,
      correo,
      password,
      rol,
      senescyt || '',
    ]);

    return res.status(201).json({
      exito: true,
      mensaje: 'Profesional registrado con éxito',
      id: resultado.rows[0].id,
    });
  } catch (err) {
    if (err.message.includes('unique constraint') || err.code === '23505') {
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
});

// GET /api/profesionales - Listar
app.get('/api/profesionales', async (req, res) => {
  try {
    const sql = `SELECT id, nombre, cedula, correo, rol, senescyt FROM profesionales`;
    const resultado = await pool.query(sql);
    res.status(200).json({ exito: true, profesionales: resultado.rows });
  } catch (err) {
    res.status(500).json({ exito: false, mensaje: err.message });
  }
});

// GET /api/citas - Listar
app.get('/api/citas', async (req, res) => {
  try {
    const sql = `SELECT * FROM citas ORDER BY id DESC`;
    const resultado = await pool.query(sql);
    res.status(200).json({ exito: true, citas: resultado.rows });
  } catch (err) {
    res.status(500).json({ exito: false, mensaje: 'Error al consultar citas.' });
  }
});

// POST /api/citas - Agendar
app.post('/api/citas', async (req, res) => {
  const { paciente, cedula_paciente, fecha, hora, especialidad, motivo } = req.body;

  if (!paciente || !fecha || !hora) {
    return res.status(400).json({
      exito: false,
      mensaje: 'Paciente, fecha y hora son obligatorios.',
    });
  }

  try {
    const sql = `
      INSERT INTO citas (paciente, cedula_paciente, fecha, hora, especialidad, motivo)
      VALUES ($1, $2, $3, $4, $5, $6) RETURNING id
    `;
    const resultado = await pool.query(sql, [
      paciente,
      cedula_paciente || '',
      fecha,
      hora,
      especialidad || 'Medicina General',
      motivo || 'Consulta Médica General',
    ]);

    res.status(201).json({
      exito: true,
      mensaje: 'Cita agendada correctamente',
      id: resultado.rows[0].id,
    });
  } catch (err) {
    res.status(500).json({
      exito: false,
      mensaje: 'Error en la base de datos al agendar cita.',
    });
  }
});

// GET /api/atenciones - Obtener
app.get('/api/atenciones', async (req, res) => {
  try {
    const sql = `SELECT * FROM atenciones ORDER BY id DESC`;
    const resultado = await pool.query(sql);
    res.status(200).json({ exito: true, atenciones: resultado.rows });
  } catch (err) {
    res.status(500).json({ exito: false, mensaje: 'Error al consultar registros de triaje.' });
  }
});

// POST /api/atenciones - Registrar Triaje
app.post('/api/atenciones', async (req, res) => {
  const {
    paciente,
    cedula_paciente,
    presion_arterial,
    frecuencia_cardiaca,
    temperatura,
    saturacion_oxigeno,
    clasificacion,
    observaciones,
  } = req.body;

  if (!paciente || !clasificacion) {
    return res.status(400).json({
      exito: false,
      mensaje: 'El paciente y la clasificación son obligatorios.',
    });
  }

  const fechaHoy = new Date().toISOString().split('T')[0];

  try {
    const sql = `
      INSERT INTO atenciones 
      (paciente, cedula_paciente, presion_arterial, frecuencia_cardiaca, temperatura, saturacion_oxigeno, clasificacion, observaciones, fecha)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id
    `;
    const resultado = await pool.query(sql, [
      paciente,
      cedula_paciente || '',
      presion_arterial || '120/80',
      frecuencia_cardiaca || '75 bpm',
      temperatura || '36.5 °C',
      saturacion_oxigeno || '98%',
      clasificacion,
      observaciones || '',
      fechaHoy,
    ]);

    res.status(201).json({
      exito: true,
      mensaje: 'Triaje registrado correctamente',
      id: resultado.rows[0].id,
    });
  } catch (err) {
    res.status(500).json({
      exito: false,
      mensaje: 'Error al guardar la ficha de triaje en la BD.',
    });
  }
});

// GET /api/brigadas - Listar
app.get('/api/brigadas', async (req, res) => {
  try {
    const sql = `SELECT * FROM brigadas ORDER BY id DESC`;
    const resultado = await pool.query(sql);
    res.status(200).json({ exito: true, brigadas: resultado.rows });
  } catch (err) {
    res.status(500).json({ exito: false, mensaje: 'Error al consultar brigadas.' });
  }
});

// POST /api/brigadas - Registrar
app.post('/api/brigadas', async (req, res) => {
  const { nombre_brigada, lugar, latitud, longitud, fecha, observaciones } = req.body;

  if (!nombre_brigada || !lugar || !fecha) {
    return res.status(400).json({
      exito: false,
      mensaje: 'El nombre, lugar y fecha son obligatorios.',
    });
  }

  try {
    const sql = `
      INSERT INTO brigadas (nombre_brigada, lugar, latitud, longitud, fecha, observaciones)
      VALUES ($1, $2, $3, $4, $5, $6) RETURNING id
    `;
    const resultado = await pool.query(sql, [
      nombre_brigada,
      lugar,
      latitud || -0.1807,
      longitud || -78.4678,
      fecha,
      observaciones || '',
    ]);

    res.status(201).json({
      exito: true,
      mensaje: 'Brigada agendada exitosamente',
      id: resultado.rows[0].id,
    });
  } catch (err) {
    res.status(500).json({
      exito: false,
      mensaje: 'Error al registrar la brigada en la base de datos.',
    });
  }
});

// Arrancar Servidor
app.listen(PORT, () => {
  console.log(`Servidor Central TeleMedicina corriendo en el puerto ${PORT}`);
});