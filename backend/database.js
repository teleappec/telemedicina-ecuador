const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.resolve(__dirname, 'telemedicina.db');
const db = new sqlite3.Database(dbPath);

db.serialize(() => {
  // 1. Tabla de Usuarios y Roles
  db.run(`
    CREATE TABLE IF NOT EXISTS usuarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cedula TEXT UNIQUE NOT NULL,
      nombre TEXT NOT NULL,
      email TEXT,
      rol TEXT CHECK(rol IN ('PACIENTE', 'MEDICO', 'ENFERMERO', 'ADMIN')) NOT NULL,
      senescyt TEXT,
      especialidad TEXT,
      precio_consulta REAL DEFAULT 0.0,
      estado TEXT DEFAULT 'ACTIVO'
    )
  `);

  // 2. Tabla de Especialidades y Comisiones de la App
  db.run(`
    CREATE TABLE IF NOT EXISTS especialidades (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT UNIQUE NOT NULL,
      precio_sugerido REAL NOT NULL,
      comision_porcentaje REAL DEFAULT 15.0
    )
  `);

  // 3. Tabla de Citas y Transacciones Financieras
  db.run(`
    CREATE TABLE IF NOT EXISTS citas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      paciente_id INTEGER,
      medico_id INTEGER,
      especialidad TEXT NOT NULL,
      precio_total REAL NOT NULL,
      comision_app REAL NOT NULL,
      pago_medico REAL NOT NULL,
      estado TEXT DEFAULT 'PENDIENTE',
      fecha TEXT NOT NULL
    )
  `);

  // Sembrado de especialidades por defecto
  const stmt = db.prepare(`INSERT OR IGNORE INTO especialidades (nombre, precio_sugerido, comision_porcentaje) VALUES (?, ?, ?)`);
  stmt.run("Medicina General", 20.00, 15.0); // 15% para la app ($3.00)
  stmt.run("Pediatría", 30.00, 15.0);        // 15% para la app ($4.50)
  stmt.run("Dermatología", 35.00, 20.0);      // 20% para la app ($7.00)
  stmt.run("Enfermería a Domicilio", 15.00, 10.0); // 10% para la app ($1.50)
  stmt.finalize();

  // Sembrado de médicos y enfermeros iniciales
  const stmtMed = db.prepare(`INSERT OR IGNORE INTO usuarios (cedula, nombre, rol, senescyt, especialidad, precio_consulta) VALUES (?, ?, ?, ?, ?, ?)`);
  stmtMed.run("1712345678", "Dra. María Elena Paredes", "MEDICO", "1005-2022-8844", "Medicina General", 20.00);
  stmtMed.run("1721109351", "Enf. Carlos Mendoza", "ENFERMERO", "1005-2025-2514", "Enfermería a Domicilio", 15.00);
  stmtMed.finalize();
});

module.exports = db;