<?php
if (!empty($_POST['btn-registrar'])) {

    if (
        !empty($_POST['NumeroDeDocumento']) &&
        !empty($_POST['idTiposDeDocumentos']) &&
        !empty($_POST['Nombre1']) &&
        !empty($_POST['Apellido1']) &&
        !empty($_POST['Genero']) &&
        !empty($_POST['Telefono']) &&
        !empty($_POST['Direccion']) &&
        !empty($_POST['FechaDeNacimiento']) &&
        !empty($_POST['correo']) &&
        !empty($_POST['contrasena']) &&
        !empty($_POST['TipoDeRol'])
    ) {
        // Asignar datos del formulario
        $NumeroDeDocumento = $_POST['NumeroDeDocumento'];
        $idTiposDeDocumentos = $_POST['idTiposDeDocumentos'];
        $Nombre1 = $_POST['Nombre1'];
        $Nombre2 = $_POST['Nombre2'] ?? '';  // Campo opcional
        $Apellido1 = $_POST['Apellido1'];
        $Apellido2 = $_POST['Apellido2'] ?? ''; // Campo opcional
        $Genero = $_POST['Genero'];
        $Telefono = $_POST['Telefono'];
        $Direccion = $_POST['Direccion'];
        $FechaDeNacimiento = $_POST['FechaDeNacimiento'];
        $correo = $_POST['correo'];
        $contrasena = $_POST['contrasena'];
        $TipoDeRol = $_POST['TipoDeRol'];


        // Insertar en la base de datos
        $sql = "INSERT INTO personas (
                    NumeroDeDocumento, idTiposDeDocumentos, Nombre1, Nombre2, 
                    Apellido1, Apellido2, Genero, Telefono, Direccion, 
                    FechaDeNacimiento, correo, contraseña, TipoDeRol
                ) VALUES (
                    '$NumeroDeDocumento', '$idTiposDeDocumentos', '$Nombre1', '$Nombre2', 
                    '$Apellido1', '$Apellido2', '$Genero', '$Telefono', '$Direccion', 
                    '$FechaDeNacimiento', '$correo', '$contrasena', '$TipoDeRol'
                )";

        $resultado = $conexion->query($sql);

        if ($resultado) {
            echo '<div class="alert alert-success text-center fw-bold">✅ Usuario registrado correctamente.</div>';
        } else {
            echo '<div class="alert alert-danger text-center fw-bold">❌ Error al registrar el usuario.</div>';
        }
    } else {
        echo '<div class="alert alert-warning text-center fw-bold">⚠️ Por favor completa todos los campos obligatorios.</div>';
    }
}
?>
