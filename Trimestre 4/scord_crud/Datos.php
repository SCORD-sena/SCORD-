<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Jugadores Registrados</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://kit.fontawesome.com/23d6c9afd5.js" crossorigin="anonymous"></script>
  <link rel="stylesheet" href="Css/InicioJugador.css">
  <link href="https://cdn.datatables.net/v/bs5/dt-2.3.2/datatables.min.css" rel="stylesheet" integrity="sha384-nt2TuLL4RlRQ9x6VTFgp009QD7QLRCYX17dKj9bj51w2jtWUGFMVTveRXfdgrUdx" crossorigin="anonymous">
</head>

<body class="bg-light d-flex flex-column min-vh-100">
  <script>
    function eliminar() {
      return confirm("¿Estás seguro de eliminar esta persona?");
    }
  </script>

<!-- Header -->
<header class="header bg-white shadow-sm py-3">
  <nav class="navbar container d-flex align-items-center justify-content-between flex-wrap">
    <div class="d-flex align-items-center">
      <img src="Img/logo.jpg" alt="Logo SCORD" class="me-2" style="height: 50px;" />
      <h4 class="mb-0 text-danger fw-bold">SCORD</h4>
    </div>
    <label class="labe_hamburguesa d-md-none" for="menu_hamburguesa">
      <svg xmlns="http://www.w3.org/2000/svg" width="35" height="35" fill="#e63946" viewBox="0 0 16 16">
        <path fill-rule="evenodd" d="M2.5 12a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5zm0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5z" />
      </svg>
    </label>
    <input class="menu_hamburguesa d-none" type="checkbox" id="menu_hamburguesa" />
    <ul class="ul_links nav flex-md-row flex-column">
      <li class="nav-item"><a href="InicioAdmin.html" class="nav-link text-black">Inicio</a></li>
      <li class="nav-item"><a href="CrEntrenadorAdmin.html" class="nav-link text-black">Cronograma Admin</a></li>
      <li class="nav-item"><a href="PerfilJugadorAdmin.html" class="nav-link text-black">Perfil Jugador</a></li>
      <li class="nav-item"><a href="PerEntrenadorAdmin.html" class="nav-link text-black">Perfil Entrenador</a></li>
      <li class="nav-item"><a href="EstJJugadorAdmin.html" class="nav-link text-black">Evaluar Jugadores</a></li>
      <li class="nav-item"><a href="AgregarUsu.php" class="nav-link text-black">Agregar Usuario</a></li>
      <li class="nav-item"><a href="Datos.php" class="nav-link text-danger">Datos</a></li>
      <li class="nav-item"><a href="CerrarSesion.html" class="nav-link btn btn-outline-danger btn-sm">Cerrar Sesión</a></li>
    </ul>
  </nav>
</header>

<!-- Contenido principal -->
<main class="container my-5 flex-grow-1">
  <h1 class="text-danger mb-4 text-center">Jugadores Registrados</h1>
  <?php
   include 'Modelo/conexion.php'; // Asegúrate de que la conexión a la base de datos esté establecida
   include 'controlador/eliminar_persona.php';

?>

  <div class="table-responsive">
    <table class="table table-striped table-hover table-bordered align-middle text-center table-responsive" id="datos">
  <thead class="table-danger">
    <tr>
      <th class="align-middle">Numero De Documento</th>
      <th class="align-middle">Primer Nombre</th>
      <th class="align-middle">Segundo Nombre</th>
      <th class="align-middle">Primer Apellido</th>
      <th class="align-middle">Segundo Apellido</th>
      <th class="align-middle">Genero</th>
      <th class="align-middle">Teléfono</th>
      <th class="align-middle">Dirección</th>
      <th class="align-middle">Fecha De Nacimiento</th>
      <th class="align-middle">Correo</th>
      <th class="align-middle">Contraseña</th>
      <th class="align-middle">Rol</th>
      <th class="align-middle">Tipo Documento</th>
    </tr>
  </thead>
      <tbody>
      
      <?php
      $sql = $conexion->query("SELECT * FROM personas");
      while ($datos = $sql->fetch_object()) {
    
      ?>

          <tr>
          <td><?= $datos->NumeroDeDocumento ?></td>
          <td><?= $datos->Nombre1 ?></td>
          <td><?= $datos->Nombre2 ?></td>
          <td><?= $datos->Apellido1 ?></td>
          <td><?= $datos->Apellido2 ?></td>
          <td><?= $datos->Genero ?></td>
          <td><?= $datos->Telefono ?></td>
          <td><?= $datos->Direccion ?></td>
          <td><?= $datos->FechaDeNacimiento ?></td>
          <td><?= $datos->correo ?></td>
          <td><?= $datos->contraseña ?></td>
          <td><?= $datos->TipoDeRol ?></td>
            <td>

            <!--Botones-->
            <div class="d-flex justify-content-center gap-2"> <a href="modificar_datos.php?NumeroDeDocumento=<?= $datos->NumeroDeDocumento ?>" class="btn btn-sm btn-warning" title="Editar"><i class="fa-solid fa-user-pen"></i></a>
            <a onclick="return eliminar()" href="datos.php?NumeroDeDocumento=<?=$datos->NumeroDeDocumento?>" class="btn btn-sm btn-danger" title="Eliminar"><i class="fa-solid fa-trash"></i></a>
             </div>    

             
            </td>
          </tr>
        <?php } 
        ?>
      </tbody>
    </table>
  </div>
</main>

<!-- Footer -->
<footer class="bg-dark text-white py-4 mt-auto">
  <div class="container">
    <div class="row text-center text-md-start justify-content-center">
      <div class="col-md-4 mb-3">
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
        
<script src="https://code.jquery.com/jquery-3.7.1.min.js" integrity="sha256-/JqT3SQfawRcv/BIHPThkBvs0OEvtFFmqPF/lYI/Cxo=" crossorigin="anonymous"></script>
 
<script src="https://cdn.datatables.net/v/bs5/dt-2.3.2/datatables.min.js" integrity="sha384-rL0MBj9uZEDNQEfrmF51TAYo90+AinpwWp2+duU1VDW/RG7flzbPjbqEI3hlSRUv" crossorigin="anonymous"></script>

<script>
  var table = new DataTable('#datos', {
    language: {
        url: 'https://cdn.datatables.net/plug-ins/2.3.2/i18n/es-CO.json',
    },
});
</script>

</body>
</html>
