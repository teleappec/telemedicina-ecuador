const express = require('express');
const cors = require('cors');
const db = require('./database');

const app = express();
app.use(cors());
app.use(express.json());

const pacientesOffline = [];

// 1. Validar Médico / Enfermero
app.post('/api/validar-medico', (req, res) => {
  const { cedula, senescyt } = req.body;
  const sql = `SELECT * FROM usuarios WHERE cedula = ? AND senescyt = ? AND estado = 'ACTIVO'`;
  db.get(sql, [cedula, senescyt], (err, row) => {
    if (err) return res.status(500).json({ exito: false, mensaje: "Error en base de datos" });
    if (row) {
      return res.json({ exito: true, medico: row });
    } else {
      return res.status(404).json({ exito: false, mensaje: "Cédula o SENESCYT no autorizados." });
    }
  });
});

// 2. Registrar nuevo profesional para aprobación
app.post('/api/admin/registrar-medico', (req, res) => {
  const { cedula, nombre, senescyt, especialidad, precio } = req.body;
  const sql = `INSERT INTO usuarios (cedula, nombre, rol, senescyt, especialidad, precio_consulta, estado) VALUES (?, ?, 'MEDICO', ?, ?, ?, 'ACTIVO')`;
  db.run(sql, [cedula, nombre, senescyt, especialidad, precio || 20.0], function(err) {
    if (err) return res.status(400).json({ exito: false, mensaje: "La cédula ya está registrada." });
    res.json({ exito: true, mensaje: "Profesional registrado y activado con éxito." });
  });
});

// 3. Catalogo de Especialidades
app.get('/api/especialidades', (req, res) => {
  db.all(`SELECT * FROM especialidades`, [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ especialidades: rows });
  });
});

// 4. Reservar Cita Virtual
app.post('/api/citas/reservar', (req, res) => {
  const { especialidad, precio } = req.body;
  db.get(`SELECT comision_porcentaje FROM especialidades WHERE nombre = ?`, [especialidad], (err, esp) => {
    const pct = esp ? esp.comision_porcentaje : 15.0;
    const comisionApp = (precio * pct) / 100;
    const pagoMedico = precio - comisionApp;

    const sql = `INSERT INTO citas (especialidad, precio_total, comision_app, pago_medico, fecha) VALUES (?, ?, ?, ?, ?)`;
    db.run(sql, [especialidad, precio, comisionApp, pagoMedico, new Date().toISOString()], function(err) {
      if (err) return res.status(500).json({ exito: false, mensaje: err.message });
      res.json({
        exito: true,
        citaId: this.lastID,
        desglose: { totalCobrado: precio, comisionPlataforma: comisionApp, gananciaMedico: pagoMedico }
      });
    });
  });
});

// 5. Solicitar Enfermero/a a Domicilio
app.post('/api/enfermeria/solicitar', (req, res) => {
  const precio = 15.00;
  const comisionApp = 1.50;
  const pagoEnfermero = 13.50;

  const sql = `INSERT INTO citas (especialidad, precio_total, comision_app, pago_medico, fecha) VALUES (?, ?, ?, ?, ?)`;
  db.run(sql, ['Enfermería a Domicilio', precio, comisionApp, pagoEnfermero, new Date().toISOString()], function(err) {
    if (err) return res.status(500).json({ exito: false, mensaje: err.message });
    res.json({
      exito: true,
      solicitudId: this.lastID,
      desglose: { totalCobrado: precio, comisionPlataforma: comisionApp, gananciaEnfermero: pagoEnfermero }
    });
  });
});

// 6. Sincronizar Pacientes Offline
app.post('/api/sincronizar', (req, res) => {
  const { pacientes } = req.body;
  if (Array.isArray(pacientes) && pacientes.length > 0) {
    const pacientesConGps = pacientes.map(p => ({
      ...p,
      latitud: p.latitud || "-0.180653",
      longitud: p.longitud || "-78.467838"
    }));
    pacientesOffline.push(...pacientesConGps);
    return res.json({ exito: true, mensaje: `Sincronización exitosa. ${pacientes.length} registros guardados.` });
  }
  return res.status(400).json({ exito: false, mensaje: "No hay datos para sincronizar." });
});

// 7. Vista Imprimible / Reporte Oficial para GADs
app.get('/reporte/imprimir', (req, res) => {
  const filas = pacientesOffline.map(p => `
    <tr>
      <td>${p.fecha ? p.fecha.split('T')[0] : '2026-08-19'}</td>
      <td>${p.nombre}</td>
      <td>${p.cedula}</td>
      <td>${p.presion} mmHg</td>
      <td>${p.temp} °C</td>
      <td>${p.oxigeno}%</td>
      <td><strong>${p.prioridad}</strong></td>
      <td>${p.atendidoPor}</td>
    </tr>
  `).join('');

  res.send(`
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8">
      <title>Reporte Oficial de Triaje de Campo</title>
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="p-5" onload="window.print()">
      <div class="text-center mb-4">
        <h2>REPORTE EPIDEMIOLÓGICO Y TRIAJE DE CAMPO</h2>
        <p class="text-muted">Convenio TeleMedicina Ecuador - GAD Municipal / Universidad</p>
        <hr>
      </div>
      <table class="table table-bordered">
        <thead class="table-dark">
          <tr><th>Fecha</th><th>Paciente</th><th>Cédula</th><th>P. Arterial</th><th>Temp.</th><th>SpO2</th><th>Prioridad</th><th>Atendido Por</th></tr>
        </thead>
        <tbody>${filas.length ? filas : '<tr><td colspan="8" class="text-center">Sin registros.</td></tr>'}</tbody>
      </table>
      <div class="mt-5 row text-center">
        <div class="col-6"><p>_______________________<br>Firma Coordinador de Brigada</p></div>
        <div class="col-6"><p>_______________________<br>Sello Centro de Salud / GAD</p></div>
      </div>
    </body>
    </html>
  `);
});

// 8. Dashboard Principal
app.get('/dashboard', (req, res) => {
  db.all(`SELECT * FROM citas`, [], (err, citas) => {
    const totalComisiones = citas ? citas.reduce((acc, c) => acc + c.comision_app, 0) : 0;
    const totalVentas = citas ? citas.reduce((acc, c) => acc + c.precio_total, 0) : 0;

    const filasCitas = (citas || []).map(c => `
      <tr>
        <td>#${c.id}</td>
        <td><strong>${c.especialidad}</strong></td>
        <td>$${c.precio_total.toFixed(2)}</td>
        <td class="text-success fw-bold">+$${c.comision_app.toFixed(2)}</td>
        <td>$${c.pago_medico.toFixed(2)}</td>
        <td>${c.fecha.split('T')[0]}</td>
      </tr>
    `).join('');

    const filasTriaje = pacientesOffline.map(p => {
      let badge = 'bg-success';
      if (p.colorRiesgo === 'ROJO') badge = 'bg-danger';
      if (p.colorRiesgo === 'AMARILLO') badge = 'bg-warning text-dark';

      return `
        <tr>
          <td><span class="badge ${badge}">${p.prioridad || 'ESTABLE'}</span></td>
          <td><strong>${p.nombre}</strong></td>
          <td>${p.cedula}</td>
          <td>${p.presion} | ${p.temp}°C | ${p.oxigeno}%</td>
          <td>${p.atendidoPor || 'Brigadista'}</td>
          <td>
            <a href="https://maps.google.com/?q=${p.latitud || '-0.180653'},${p.longitud || '-78.467838'}" target="_blank" class="btn btn-sm btn-outline-primary">
              📍 Ver Mapa
            </a>
          </td>
        </tr>
      `;
    }).join('');

    res.send(`
      <!DOCTYPE html>
      <html lang="es">
      <head>
        <meta charset="UTF-8">
        <title>TeleMedicina Ecuador - Panel de Control</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
      </head>
      <body class="bg-light p-4">
        <div class="container bg-white p-4 rounded shadow-sm">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <h2>🏥 TeleMedicina Ecuador - Central Administrativa</h2>
            <div>
              <a href="/reporte/imprimir" target="_blank" class="btn btn-danger me-2">📄 Exportar PDF / Reporte GAD</a>
              <button onclick="location.reload()" class="btn btn-outline-secondary">🔄 Actualizar</button>
            </div>
          </div>
          
          <div class="row text-center mb-4">
            <div class="col-md-4">
              <div class="card text-white p-3 bg-success">
                <h6>Ganancias Netas App</h6>
                <h3>$${totalComisiones.toFixed(2)}</h3>
              </div>
            </div>
            <div class="col-md-4">
              <div class="card bg-primary text-white p-3">
                <h6>Volumen Transaccionado</h6>
                <h3>$${totalVentas.toFixed(2)}</h3>
              </div>
            </div>
            <div class="col-md-4">
              <div class="card bg-dark text-white p-3">
                <h6>Pacientes de Brigada</h6>
                <h3>${pacientesOffline.length}</h3>
              </div>
            </div>
          </div>

          <ul class="nav nav-tabs" id="myTab" role="tablist">
            <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#citas">💰 Transacciones y Comisiones</button></li>
            <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#brigadas">🚨 Triajes de Campo (GADs con GPS)</button></li>
          </ul>

          <div class="tab-content pt-3">
            <div class="tab-pane fade show active" id="citas">
              <table class="table table-striped">
                <thead><tr><th>ID</th><th>Servicio / Especialidad</th><th>Monto Total</th><th>Tu Comisión</th><th>Pago Profesional</th><th>Fecha</th></tr></thead>
                <tbody>${filasCitas.length ? filasCitas : '<tr><td colspan="6" class="text-center text-muted">Sin transacciones aún.</td></tr>'}</tbody>
              </table>
            </div>
            <div class="tab-pane fade" id="brigadas">
              <table class="table table-hover">
                <thead><tr><th>Estado</th><th>Paciente</th><th>Cédula</th><th>Signos Vitales</th><th>Atendido Por</th><th>Ubicación GPS</th></tr></thead>
                <tbody>${filasTriaje.length ? filasTriaje : '<tr><td colspan="6" class="text-center text-muted">Sin pacientes de brigada sincronizados.</td></tr>'}</tbody>
              </table>
            </div>
          </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
      </body>
      </html>
    `);
  });
});

// Usar el puerto asignado por Render/Railway o 3000 por defecto en local
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor Central TeleMedicina corriendo en puerto ${PORT}`);
});