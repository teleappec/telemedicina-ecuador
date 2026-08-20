// server.js
const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// Conexión a Base de Datos SQLite
const db = new sqlite3.Database('./telemedicina.db', (err) => {
  if (err) console.error('Error al conectar BD:', err.message);
  else console.log('Conectado a la base de datos SQLite.');
});

// Inicialización de Tablas
db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS solicitudes (
      id TEXT PRIMARY KEY,
      tipo TEXT,
      detalle TEXT,
      profesional TEXT,
      fechaHora TEXT,
      monto REAL,
      estado TEXT
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS recetas (
      id TEXT PRIMARY KEY,
      pacienteNombre TEXT,
      doctorNombre TEXT,
      diagnostico TEXT,
      medicamentos TEXT,
      fecha TEXT
    )
  `);
});

// GET: Obtener todas las citas/solicitudes
app.get('/api/solicitudes', (req, res) => {
  db.all('SELECT * FROM solicitudes ORDER BY rowid DESC', [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// POST: Registrar una nueva solicitud de atención o cita
app.post('/api/solicitudes', (req, res) => {
  const { id, tipo, detalle, profesional, fechaHora, monto, estado } = req.body;
  const sql = `INSERT INTO solicitudes (id, tipo, detalle, profesional, fechaHora, monto, estado) 
               VALUES (?, ?, ?, ?, ?, ?, ?)`;
  const params = [id, tipo, detalle, profesional, fechaHora, monto, estado || 'Confirmada'];

  db.run(sql, params, function (err) {
    if (err) return res.status(400).json({ error: err.message });
    res.json({ message: 'Solicitud guardada con éxito', id });
  });
});

// GET: Obtener recetas médicas
app.get('/api/recetas', (req, res) => {
  db.all('SELECT * FROM recetas', [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// POST: Guardar receta médica
app.post('/api/recetas', (req, res) => {
  const { id, pacienteNombre, doctorNombre, diagnostico, medicamentos, fecha } = req.body;
  const sql = `INSERT INTO recetas (id, pacienteNombre, doctorNombre, diagnostico, medicamentos, fecha) 
               VALUES (?, ?, ?, ?, ?, ?)`;
  db.run(sql, [id, pacienteNombre, doctorNombre, diagnostico, JSON.stringify(medicamentos), fecha], function (err) {
    if (err) return res.status(400).json({ error: err.message });
    res.json({ message: 'Receta registrada correctamente' });
  });
});

app.listen(PORT, () => {
  console.log(`Servidor de Telemedicina corriendo en http://localhost:${PORT}`);
});