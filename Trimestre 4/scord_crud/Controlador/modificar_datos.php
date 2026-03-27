<?php

if(!empty($_POST["btn-registrar"])){
    $NumeroDeDocumento = $_POST["NumeroDeDocumento"];
    $nombre1 = $_POST["Nombre1"];
    $nombre2 = $_POST["Nombre2"];
    $apellido1 = $_POST["Apellido1"];
    $apellido2 = $_POST["Apellido2"];
    $genero = $_POST["Genero"];
    $telefono = $_POST["Telefono"];
    $direccion = $_POST["Direccion"];
    $fecha_nacimiento = $_POST["FechaDeNacimiento"];
    $correo = $_POST["correo"];
    $contraseña = $_POST["contraseña"];
    $tipoderol = $_POST["TipoDeRol"];


    $sql = $conexion->query("UPDATE personas SET NumeroDeDocumento='$NumeroDeDocumento', 
    Nombre1='$nombre1',
    Nombre2='$nombre2', 
    Apellido1='$apellido1',
    Apellido2='$apellido2',
    Genero='$genero',
    Telefono='$telefono',
    Direccion='$direccion',
    FechaDeNacimiento='$fecha_nacimiento',
    correo='$correo',
    contraseña='$contraseña', 
    idTiposDeDocumentos='$_POST[idTiposDeDocumentos]' 
    where NumeroDeDocumento='$NumeroDeDocumento'");


if ($sql) {
    header("Location:datos.php");
    exit();
}


}

?>