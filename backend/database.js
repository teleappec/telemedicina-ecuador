const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.resolve(__dirname, 'telemedicina.db');
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error al conectar con SQLite:', err.message);
  } else {
    console.log('Base de datos SQLite conectada correctamente.');
  }
});

db.serialize(() => {
  // Tabla de Citas
  db.run(`CREATE TABLE IF NOT EXISTS citas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    especialidad TEXT,
    doctor TEXT,
    fecha TEXT,
    hora TEXT
  )`);

  // Tabla de Triaje / Pacientes
  db.run(`CREATE TABLE IF NOT EXISTS pacientes_triaje (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    datos TEXT,
    creado_en DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  // Tabla de Historial Médico
  db.run(`CREATE TABLE IF NOT EXISTS historial (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    diagnostico TEXT,
    fecha TEXT,
    doctor TEXT
  )`);
});

module.exports = db;