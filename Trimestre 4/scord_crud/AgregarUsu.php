<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Agregar Usuario - SCORD</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="Css/InicioJugador.css">

</head>
<body class="bg-light">

  <!-- Header -->
  <header class="header bg-white shadow-sm py-3">
    <nav class="navbar container d-flex align-items-center justify-content-between flex-wrap">
      <div class="d-flex align-items-center">
        <img src="Img/logo.jpg" alt="Logo SCORD" class="me-2" style="height: 50px;" />
        <h4 class="mb-0 text-danger fw-bold">SCORD</h4>
      </div>
      <label class="labe_hamburguesa d-md-none" for="menu_hamburguesa">
        <svg xmlns="http://www.w3.org/2000/svg" width="35" height="35" fill="#e63946" viewBox="0 0 16 16">
          <path fill-rule="evenodd"
            d="M2.5 12a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5z" />
        </svg>
      </label>
      <input class="menu_hamburguesa d-none" type="checkbox" id="menu_hamburguesa" />
      <ul class="ul_links nav flex-md-row flex-column">
        <li class="nav-item"><a href="InicioAdmin.html" class="nav-link text-black">Inicio</a></li>
        <li class="nav-item"><a href="CrEntrenadorAdmin.html" class="nav-link text-black">Cronograma Admin</a></li>
        <li class="nav-item"><a href="PerfilJugadorAdmin.html" class="nav-link text-black">Perfil Jugador</a></li>
        <li class="nav-item"><a href="PerEntrenadorAdmin.html" class="nav-link text-black">Perfil Entrenador</a></li>
        <li class="nav-item"><a href="EstJJugadorAdmin.html" class="nav-link text-black">Evaluar Jugadores</a></li>
        <li class="nav-item"><a href="AgregarUsu.html" class="nav-link text-danger">Agregar Usuario</a></li>
        <li class="nav-item"><a href="Datos.php" class="nav-link text-black">Datos</a></li>
        <li class="nav-item"><a href="CerrarSesion.html" class="nav-link btn btn-outline-danger btn-sm">Cerrar Sesión</a></li>
      </ul>
    </nav>
  </header>

  <!-- Contenido principal -->
<main class="container my-5">
  <div class="text-center mb-4">
    <h1 class="text-danger">Agregar Usuario</h1>
    <?php
      include "modelo/conexion.php";
      if (!$conexion) {
        die("Error de conexión: " . mysqli_connect_error());
      }
      include "Controlador/registro_persona.php";
    ?>
  </div>

  <div class="card shadow-sm p-4">
  <form class="row g-4" method="post" enctype="multipart/form-data">
    <!-- Columna Izquierda -->
    <div class="col-md-6">
      <div class="mb-3">
        <label for="documento" class="form-label">Número de Documento</label>
        <input type="number" id="documento" name="NumeroDeDocumento" class="form-control" required>
      </div>
      <div class="mb-3">
        <label for="id_tipo_doc" class="form-label">Tipo de Documento</label>
        <select id="id_tipo_doc" name="idTiposDeDocumentos" class="form-select" required>
          <option value="">Seleccionar</option>
          <option value="1">Cédula de Ciudadanía</option>
          <option value="2">Tarjeta de Identidad</option>
          <option value="3">Cédula de Extranjería</option>
        </select>
      </div>
      <div class="mb-3">
        <label for="nombre1" class="form-label">Primer Nombre</label>
        <input type="text" id="nombre1" name="Nombre1" class="form-control" required>
      </div>
      <div class="mb-3">
        <label for="nombre2" class="form-label">Segundo Nombre</label>
        <input type="text" id="nombre2" name="Nombre2" class="form-control">
      </div>
      <div class="mb-3">
        <label for="apellido1" class="form-label">Primer Apellido</label>
        <input type="text" id="apellido1" name="Apellido1" class="form-control" required>
      </div>
      <div class="mb-3">
        <label for="apellido2" class="form-label">Segundo Apellido</label>
        <input type="text" id="apellido2" name="Apellido2" class="form-control">
      </div>
      <div class="mb-3">
        <label for="genero" class="form-label">Género</label>
        <select id="genero" name="Genero" class="form-select" required>
          <option value="">Seleccionar</option>
          <option value="masculino">Masculino</option>
          <option value="femenino">Femenino</option>
        </select>
      </div>
    </div>

    <!-- Columna Derecha -->
    <div class="col-md-6">
      <div class="mb-3">
        <label for="telefono" class="form-label">Teléfono</label>
        <input type="tel" id="telefono" name="Telefono" class="form-control" required>
      </div>
      <div class="mb-3">
        <label for="direccion" class="form-label">Dirección</label>
        <input type="text" id="direccion" name="Direccion" class="form-control" required>
      </div>
      <div class="mb-3">
        <label for="fecha_nacimiento" class="form-label">Fecha de Nacimiento</label>
        <input type="date" id="fecha_nacimiento" name="FechaDeNacimiento" class="form-control" required>
      </div>
      <div class="mb-3">
        <label for="correo" class="form-label">Correo Electrónico</label>
        <input type="email" id="correo" name="correo" class="form-control" required>
      </div>
      <div class="mb-3">
        <label for="contrasena" class="form-label">Contraseña</label>
        <input type="password" id="contrasena" name="contrasena" class="form-control" required>
      </div>
      <div class="mb-3">
        <label for="tipo_rol" class="form-label">Tipo de Rol</label>
        <select id="tipo_rol" name="TipoDeRol" class="form-select" required>
          <option value="">Seleccionar</option>
          <option value="jugador">Jugador</option>
          <option value="entrenador">Entrenador</option>
          <option value="administrador">Administrador</option>
        </select>
      </div>

      <!-- Botón alineado con tipo de documento -->
    <br>
    <br>
    <br>
    <br>  
      <div class="col-12 d-flex justify-content-end gap-3">
      <button type="submit" class="btn btn-danger" name="btn-registrar" value="ok">Guardar Usuario</button>
      <button type="reset" class="btn btn-danger">Cancelar</button>
    </div>
</div>
  </form>
</main>

  <!-- Footer -->
  <footer class="bg-dark text-white py-4">
    <div class="container">
      <div class="row text-center text-md-start justify-content-center">
        <div class="col-md-4 mb-1">
          <h3 class="text-danger">SCORD</h3>
          <p>Sistema de control y organización deportiva</p>
        </div>
        <div class="col-md-4 mb-3">
          <h3 class="text-danger">Escuela Quilmes</h3>
          <p>Formando talentos para el futuro</p>
        </div>
      </div>
      <hr class="border-light">
      <p class="text-center mb-0 small">
        &copy; 2025 SCORD | Escuela de Fútbol Quilmes | Todos los derechos reservados
      </p>
    </div>
  </footer>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
