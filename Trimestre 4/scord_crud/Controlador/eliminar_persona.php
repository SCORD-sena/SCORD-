<?php

if (!empty($_GET['NumeroDeDocumento'])) {
    $NumeroDeDocumento = $_GET['NumeroDeDocumento'];

    // 1) Busca todos los jugadores asociados a esa persona
    $result = $conexion->query("SELECT idJugadores FROM jugadores WHERE NumeroDeDocumento='$NumeroDeDocumento'");
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            $idJugador = $row['idJugadores'];

            // 2) Borra registros dependientes en RendimientosPartidos
            $conexion->query("DELETE FROM rendimientospartidos WHERE idJugadores='$idJugador'");
        }
    }

    // 3) Borra de Jugadores
    $conexion->query("DELETE FROM jugadores WHERE NumeroDeDocumento='$NumeroDeDocumento'");

    // 4) Borra de Entrenadores
    $conexion->query("DELETE FROM entrenadores WHERE NumeroDeDocumento='$NumeroDeDocumento'");

    // 5) Finalmente borra de Personas
    $sql = $conexion->query("DELETE FROM personas WHERE NumeroDeDocumento='$NumeroDeDocumento'");

    if ($sql == 1) {
        echo '<div class="alert alert-success d-flex justify-content-center align-items-center py-2">
        Persona eliminada correctamente
        </div>';
    } else {
        echo '<div> Error al eliminar </div>';
    }
}

?>