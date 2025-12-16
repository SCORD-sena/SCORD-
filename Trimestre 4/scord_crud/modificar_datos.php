<?php
include "modelo/conexion.php";
$NumeroDeDocumento = $_GET['NumeroDeDocumento'] ?? null;

 $sql = $conexion->query("SELECT * FROM personas WHERE NumeroDeDocumento = '$NumeroDeDocumento'");

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0"> 
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="Css/InicioJugador.css">
    <title>Document</title>
</head>
<body>
    <header class="header bg-white shadow-sm py-3">
  <nav class="navbar container d-flex align-items-center justify-content-between flex-wrap">
    <!-- Logo y título -->
    <div class="d-flex align-items-center">
      <img src="Img/logo.jpg" alt="Logo SCORD" class="me-2" style="height: 50px;" />
      <h4 class="mb-0 text-danger fw-bold">SCORD</h4>
    </div>

    <!-- Icono hamburguesa -->
    <label class="labe_hamburguesa d-md-none" for="menu_hamburguesa">
      <svg xmlns="http://www.w3.org/2000/svg" width="35" height="35" fill="#e63946" viewBox="0 0 16 16">
        <path fill-rule="evenodd"
          d="M2.5 12a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5z" />
      </svg>
    </label>

    <!-- Checkbox oculto -->
    <input class="menu_hamburguesa d-none" type="checkbox" id="menu_hamburguesa" />

    <!-- Menú de enlaces -->
    <ul class="ul_links nav flex-md-row flex-column">
      <li class="nav-item"><a href="InicioAdmin.html" class="nav-link text-black ">Inicio</a></li>
          <li class="nav-item"><a href="CrEntrenadorAdmin.html" class="nav-link text-black">Cronograma Admin</a></li>
          <li class="nav-item"><a href="PerfilJugadorAdmin.html" class="nav-link text-black">Perfil Jugador</a></li>
          <li class="nav-item"><a href="PerEntrenadorAdmin.html" class="nav-link text-black">Perfil Entrenador</a></li>
          <li class="nav-item"><a href="EstJJugadorAdmin.html" class="nav-link text-black">Evaluar Jugadores</a></li>
          <li class="nav-item"><a href="AgregarUsu." class="nav-link text-black ">Agregar Usuario</a></li>
          <li  class="nav-item"><a href="Datos.php" class="nav-link text-danger ">Datos</a></li>
          <li class="nav-item"><a href="CerrarSesion.html" class="nav-link btn btn-outline-danger btn-sm">Cerrar Sesión</a></li>
    


  </nav>
</header>

<main class="container my-5">
  <div class="text-center mb-4">
    <h1 class="text-danger">Modificar Usuario</h1>
    </div>
    <?php
    
    include "controlador/modificar_datos.php";
    while($datos = $sql->fetch_object()) { ?>

  <div class="card shadow-sm p-4">
<form class="row g-4" method="post" enctype="multipart/form-data">
<input type="hidden" name="NumeroDeDocumento_OLD" value="<?= $datos->NumeroDeDocumento ?>">   
<input type="hidden" name="NumeroDeDocumento_Original" value="<?= $datos->NumeroDeDocumento ?>">


      <!-- Columna Izquierda -->
      <div class="col-md-6">
        <div class="mb-3">
          <label for="documento" class="form-label">Número de Documento</label>
          <input type="number" id="documento" name="NumeroDeDocumento" class="form-control" value="<?= $datos->NumeroDeDocumento ?>" required>
        </div>
        <div class="mb-3">
          <label for="id_tipo_doc" class="form-label">Tipo de Documento</label>
          <select id="id_tipo_doc" name="idTiposDeDocumentos" class="form-select" required>
            <option value="">Seleccionar</option>
            <option value="1" <?= ($datos->idTiposDeDocumentos == 1) ? 'selected' : '' ?>>Cédula de Ciudadanía</option>
            <option value="2" <?= ($datos->idTiposDeDocumentos == 2) ? 'selected' : '' ?>>Tarjeta de Identidad</option>
            <option value="3" <?= ($datos->idTiposDeDocumentos == 3) ? 'selected' : '' ?>>Cédula de Extranjería</option>
          </select>
        </div>
        <div class="mb-3">
          <label for="nombre1" class="form-label">Primer Nombre</label>
          <input type="text" id="nombre1" name="Nombre1" class="form-control" value="<?= $datos->Nombre1 ?>" required>
        </div>
        <div class="mb-3">
          <label for="nombre2" class="form-label">Segundo Nombre</label>
          <input type="text" id="nombre2" name="Nombre2" class="form-control" value="<?= $datos->Nombre2 ?>">
        </div>
        <div class="mb-3">
          <label for="apellido1" class="form-label">Primer Apellido</label>
          <input type="text" id="apellido1" name="Apellido1" class="form-control" value="<?= $datos->Apellido1 ?>" required>
        </div>
        <div class="mb-3">
          <label for="apellido2" class="form-label">Segundo Apellido</label>
          <input type="text" id="apellido2" name="Apellido2" class="form-control" value="<?= $datos->Apellido2 ?>">
        </div>
        <div class="mb-3">
          <label for="genero" class="form-label">Género</label>
          <select id="genero" name="Genero" class="form-select" required>
            <option value="">Seleccionar</option>
            <option value="masculino" <?= ($datos->Genero == 'masculino') ? 'selected' : '' ?>>Masculino</option>
            <option value="femenino" <?= ($datos->Genero == 'femenino') ? 'selected' : '' ?>>Femenino</option>
          </select>
        </div>
      </div>

      <!-- Columna Derecha -->
      <div class="col-md-6">
        <div class="mb-3">
          <label for="telefono" class="form-label">Teléfono</label>
          <input type="tel" id="telefono" name="Telefono" class="form-control" value="<?= $datos->Telefono ?>" required>
        </div>
        <div class="mb-3">
          <label for="direccion" class="form-label">Dirección</label>
          <input type="text" id="direccion" name="Direccion" class="form-control" value="<?= $datos->Direccion ?>" required>
        </div>
        <div class="mb-3">
          <label for="fecha_nacimiento" class="form-label">Fecha de Nacimiento</label>
          <input type="date" id="fecha_nacimiento" name="FechaDeNacimiento" class="form-control" value="<?= $datos->FechaDeNacimiento ?>" required>
        </div>
        <div class="mb-3">
          <label for="correo" class="form-label">Correo Electrónico</label>
          <input type="email" id="correo" name="correo" class="form-control" value="<?= $datos->correo ?>" required>
        </div>
        <div class="mb-3">
          <label for="contrasena" class="form-label">Contraseña</label>
          <input type="password" id="contraseña" name="contraseña" class="form-control" value="<?= $datos->contraseña ?>" required>
        </div>
        <div class="mb-3">
          <label for="tipo_rol" class="form-label">Tipo de Rol</label>
          <select id="tipo_rol" name="TipoDeRol" class="form-select" required>
            <<option value="jugador" <?= (strtolower($datos->TipoDeRol) == 'jugador') ? 'selected' : '' ?>>Jugador</option>
<option value="entrenador" <?= (strtolower($datos->TipoDeRol) == 'entrenador') ? 'selected' : '' ?>>Entrenador</option>
<option value="administrador" <?= (strtolower($datos->TipoDeRol) == 'administrador') ? 'selected' : '' ?>>Administrador</option>
          </select>
        </div>

        <!-- Botones -->
        <div class="col-12 d-flex justify-content-end gap-3 mt-4">
          <button type="submit" class="btn btn-danger" name="btn-registrar" value="ok">Modificar Usuario</button>
          <button type="reset" class="btn btn-danger">Cancelar</button>
        </div>
      </div>
    </form>
  </div>
  </main>
<?php } ?>


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