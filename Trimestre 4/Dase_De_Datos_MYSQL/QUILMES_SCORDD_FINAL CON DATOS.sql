CREATE DATABASE  IF NOT EXISTS `scord` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_spanish2_ci */;
USE `scord`;
-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: scord
-- ------------------------------------------------------
-- Server version	5.5.5-10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categorias` (
  `idCategorias` int(11) NOT NULL COMMENT 'Identificador único de la categoria',
  `Descripcion` varchar(20) NOT NULL COMMENT 'Descripcion de la categoria (Ej. Infantil, Juvenil).',
  `TiposCategoria` int(11) NOT NULL COMMENT 'Tipo de categoria segun edad o nivel (2005, 2012).',
  PRIMARY KEY (`idCategorias`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES (301,'Sub-20',2005),(302,'Sub-19',2006),(303,'Sub-18',2007),(304,'Sub-17',2008),(305,'Sub-16',2009),(306,'Sub-15',2010),(307,'Sub-14',2011),(308,'Sub-13',2012),(309,'Sub-12',2013),(310,'Sub-11',2014),(311,'Sub-10',2015);
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `competencias`
--

DROP TABLE IF EXISTS `competencias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `competencias` (
  `idCompetencias` int(11) NOT NULL COMMENT 'Identificador unico de las competencias.',
  `NombreCompe` varchar(30) NOT NULL COMMENT 'Nombre representativo de la competencia',
  `TipoCompetencia` varchar(30) NOT NULL COMMENT 'Identifica si es liga, algun relampago, etc.',
  `Año` int(11) NOT NULL COMMENT 'Año en el que se juega o se jugo la competencia.',
  PRIMARY KEY (`idCompetencias`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `competencias`
--

LOCK TABLES `competencias` WRITE;
/*!40000 ALTER TABLE `competencias` DISABLE KEYS */;
INSERT INTO `competencias` VALUES (200,'Liga Costa','Torneos',2025),(201,'Liga Rolitos','Relámpagos',2024),(202,'Liga Magdalena','Torneos',2024),(203,'Torneo Promesas','Amistosos',2025),(204,'Torneo Nacional','Torneos',2025),(205,'Liga Sub-15','Amistosos',2024),(206,'Copa Norte','Ligas',2024),(207,'Liga Escolar','Amistosos',2025),(208,'Copa Titanes','Relámpagos',2024),(209,'Liga Sub-15','Hexagonales',2024),(210,'Liga Costa','Torneos',2024),(211,'Copa Capital','Amistosos',2024),(212,'Copa Metropolitana','Amistosos',2025),(213,'Copa Titanes','Relámpagos',2024),(214,'Liga Sub-15','Amistosos',2025),(215,'Copa Estelar','Amistosos',2024),(216,'Liga Costa','Relámpagos',2024),(217,'Copa Estelar','Torneos',2024),(218,'Copa Metropolitana','Ligas',2024),(219,'Liga Costa','Hexagonales',2024),(220,'Copa Campeones','Amistosos',2024),(221,'Torneo Barrial','Torneos',2025),(222,'Liga Costa','Relámpagos',2025),(223,'Torneo del Pacífico','Torneos',2025),(224,'Torneo Caribe','Hexagonales',2024),(225,'Copa Meta','Relámpagos',2024),(226,'Copa Colombia','Amistosos',2025),(227,'Copa Metropolitana','Torneos',2024),(228,'Torneo Promesas','Torneos',2024),(229,'Copa Norte','Ligas',2024),(230,'Torneo del Pacífico','Hexagonales',2024),(231,'Copa Estelar','Relámpagos',2024),(232,'Copa Meta','Relámpagos',2025),(233,'Torneo Sub-20','Relámpagos',2024),(234,'Torneo Caribe','Hexagonales',2024),(235,'Copa Titanes','Torneos',2024),(236,'Torneo Sub-20','Relámpagos',2024),(237,'Copa Norte','Amistosos',2024),(238,'Copa Campeones','Ligas',2024),(239,'Liga Fútbol Base','Torneos',2025),(240,'Copa Titanes','Relámpagos',2024),(241,'Liga Fútbol Base','Torneos',2024),(242,'Copa Norte','Relámpagos',2025),(243,'Torneo Sub-20','Hexagonales',2025),(244,'Liga Estudiantil','Relámpagos',2025),(245,'Copa Estelar','Relámpagos',2025),(246,'Copa Galáctica','Relámpagos',2024),(247,'Copa Llanos','Amistosos',2025),(248,'Copa Otoño','Amistosos',2025),(249,'Copa Capital','Torneos',2024);
/*!40000 ALTER TABLE `competencias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `competenciasequipos`
--

DROP TABLE IF EXISTS `competenciasequipos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `competenciasequipos` (
  `idCompetencias` int(11) NOT NULL COMMENT 'competencia en la que esta cada equipo',
  `idEquipo` int(11) NOT NULL COMMENT 'Equipo que está en cada competencia.',
  PRIMARY KEY (`idCompetencias`,`idEquipo`),
  KEY `fk_Competencias_has_Equipos_Equipos1_idx` (`idEquipo`),
  KEY `fk_Competencias_has_Equipos_Competencias1_idx` (`idCompetencias`),
  CONSTRAINT `fk_Competencias_has_Equipos_Competencias1` FOREIGN KEY (`idCompetencias`) REFERENCES `competencias` (`idCompetencias`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_Competencias_has_Equipos_Equipos1` FOREIGN KEY (`idEquipo`) REFERENCES `equipos` (`idEquipo`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `competenciasequipos`
--

LOCK TABLES `competenciasequipos` WRITE;
/*!40000 ALTER TABLE `competenciasequipos` DISABLE KEYS */;
INSERT INTO `competenciasequipos` VALUES (200,900),(201,901),(202,902),(203,903),(204,904),(205,905),(206,906),(207,907),(208,908),(209,909),(210,910),(211,911),(212,912),(213,913),(214,914),(215,915),(216,916),(217,917),(218,918),(219,919),(220,920),(221,921),(222,922),(223,923),(224,924),(225,925),(226,926),(227,927),(228,928),(229,929),(230,930),(231,931),(232,932),(233,933),(234,934),(235,935),(236,936),(237,937),(238,938),(239,939),(240,940),(241,941),(242,942),(243,943),(244,944),(245,945),(246,946),(247,947),(248,948),(249,949);
/*!40000 ALTER TABLE `competenciasequipos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cronogramas`
--

DROP TABLE IF EXISTS `cronogramas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cronogramas` (
  `idCronograma` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico del cronograma o evento.',
  `FechaDeEventos` date NOT NULL COMMENT 'Fecha en que se realiza el evento (partido o entrenamiento).',
  `TipoDeEventos` varchar(12) NOT NULL COMMENT 'Tipo de evento (Partido, Entrenamiento).',
  `CanchaPartido` varchar(30) DEFAULT NULL COMMENT 'Nombre de la cancha donde se realiza el evento',
  `Ubicacion` varchar(30) NOT NULL COMMENT 'Direccion o lugar donde se encuentra la cancha',
  `SedeEntrenamiento` varchar(30) DEFAULT NULL COMMENT 'Nombre de la sede a la que pertenece el entreno',
  `Descripcion` varchar(100) NOT NULL COMMENT 'Descripcion general del evento',
  PRIMARY KEY (`idCronograma`)
) ENGINE=InnoDB AUTO_INCREMENT=450 DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cronogramas`
--

LOCK TABLES `cronogramas` WRITE;
/*!40000 ALTER TABLE `cronogramas` DISABLE KEYS */;
INSERT INTO `cronogramas` VALUES (400,'2025-07-29','Entrenamient','','Calle 100 #14-30','Sede Sur','Control de balón'),(401,'2025-07-23','Entrenamient','','Avenida Boyacá #147-30','Sede Norte','Trabajo técnico individual'),(402,'2025-07-21','Partido','Cancha Las Ferias','Calle 8 Sur #20-50','','Encuentro oficial'),(403,'2025-07-14','Partido','Cancha Las Ferias','Calle 26 #40-12','','Encuentro oficial'),(404,'2025-08-02','Entrenamient','','Calle 26 #39-47','Sede Suba','Control de balón'),(405,'2025-07-14','Entrenamient','','Calle 72 #11-40','Sede Sur','Entrenamiento físico'),(406,'2025-07-19','Entrenamient','','Calle 26 #39-47','Sede Centro','Juego en espacio reducido'),(407,'2025-07-15','Partido','Cancha Corferias','Calle 100 #14-30','','Competencia regional'),(408,'2025-07-07','Partido','Cancha San Luis','Avenida 1 de Mayo #68-00','','Final interlocalidades'),(409,'2025-07-25','Partido','Cancha La Candelaria','Carrera 10 #52-25','','Competencia regional'),(410,'2025-07-15','Partido','Cancha Tintal','Calle 53 #28-30','','Competencia regional'),(411,'2025-07-07','Entrenamient','','Carrera 24 #63-20','Sede Sur','Trabajo técnico individual'),(412,'2025-07-19','Entrenamient','','Calle 45 #18-15','Sede Centro','Tácticas defensivas'),(413,'2025-07-29','Entrenamient','','Calle 26 #39-47','Sede Sur','Control de balón'),(414,'2025-07-29','Entrenamient','','Carrera 24 #63-20','Sede Norte','Juego en espacio reducido'),(415,'2025-08-08','Entrenamient','','Avenida Boyacá #147-30','Sede Sur','Trabajo técnico individual'),(416,'2025-07-20','Partido','Cancha La Candelaria','Avenida 1 de Mayo #68-00','','Partido contra equipo juvenil'),(417,'2025-07-25','Entrenamient','','Carrera 24 #63-20','Sede Norte','Trabajo técnico individual'),(418,'2025-08-07','Entrenamient','','Calle 26 #40-12','Sede Sur','Juego en espacio reducido'),(419,'2025-07-07','Partido','Cancha La Gaitana','Calle 26 #39-47','','Final interlocalidades'),(420,'2025-07-16','Entrenamient','','Calle 138 #103-25','Sede Sur','Juego en espacio reducido'),(421,'2025-07-30','Entrenamient','','Carrera 24 #63-20','Sede Sur','Juego en espacio reducido'),(422,'2025-08-12','Entrenamient','','Carrera 86 #6-50','Sede Suba','Tácticas defensivas'),(423,'2025-08-10','Entrenamient','','Carrera 24 #63-20','Sede Suba','Pases largos y cortos'),(424,'2025-08-06','Entrenamient','','Calle 100 #14-30','Sede Centro','Juego en espacio reducido'),(425,'2025-07-10','Entrenamient','','Avenida Suba #105-70','Sede Suba','Juego en espacio reducido'),(426,'2025-08-14','Entrenamient','','Calle 100 #14-30','Sede Suba','Entrenamiento físico'),(427,'2025-08-11','Partido','Cancha Las Ferias','Carrera 10 #52-25','','Final interlocalidades'),(428,'2025-08-14','Partido','Cancha Minuto de Dios','Calle 100 #14-30','','Competencia regional'),(429,'2025-07-23','Entrenamient','','Carrera 30 #45-03','Sede Norte','Juego en espacio reducido'),(430,'2025-08-01','Entrenamient','','Carrera 13 #65-05','Sede Sur','Ejercicios de reacción'),(431,'2025-08-14','Entrenamient','','Calle 53 #28-30','Sede Norte','Ejercicios de reacción'),(432,'2025-08-15','Entrenamient','','Calle 8 Sur #20-50','Sede Suba','Entrenamiento físico'),(433,'2025-08-15','Partido','Cancha Fontanar','Calle 80 #60-20','','Partido contra equipo juvenil'),(434,'2025-07-08','Entrenamient','','Calle 26 #40-12','Sede Suba','Entrenamiento físico'),(435,'2025-07-25','Entrenamient','','Carrera 7 #19-20','Sede Sur','Pases largos y cortos'),(436,'2025-07-10','Entrenamient','','Carrera 86 #6-50','Sede Norte','Trabajo técnico individual'),(437,'2025-07-09','Entrenamient','','Calle 80 #60-20','Sede Centro','Pases largos y cortos'),(438,'2025-08-14','Entrenamient','','Calle 26 #40-12','Sede Norte','Control de balón'),(439,'2025-07-07','Entrenamient','','Carrera 30 #45-03','Sede Suba','Tácticas defensivas'),(440,'2025-07-15','Partido','Cancha La Esmeralda','Calle 8 Sur #20-50','','Partido amistoso'),(441,'2025-07-19','Entrenamient','','Carrera 13 #65-05','Sede Suba','Tácticas defensivas'),(442,'2025-07-21','Entrenamient','','Calle 138 #103-25','Sede Centro','Pases largos y cortos'),(443,'2025-07-31','Partido','Cancha La Candelaria','Carrera 10 #52-25','','Competencia regional'),(444,'2025-08-15','Entrenamient','','Calle 100 #14-30','Sede Norte','Juego en espacio reducido'),(445,'2025-08-06','Entrenamient','','Calle 26 #39-47','Sede Suba','Entrenamiento físico'),(446,'2025-08-09','Entrenamient','','Carrera 24 #63-20','Sede Suba','Coordinación en equipo'),(447,'2025-07-12','Entrenamient','','Carrera 30 #45-03','Sede Centro','Ejercicios de reacción'),(448,'2025-07-29','Partido','Cancha Minuto de Dios','Calle 53 #28-30','','Jornada de fogueo'),(449,'2025-07-30','Entrenamient','','Avenida Boyacá #147-30','Sede Centro','Coordinación en equipo');
/*!40000 ALTER TABLE `cronogramas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entrenadores`
--

DROP TABLE IF EXISTS `entrenadores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `entrenadores` (
  `idEntrenadores` int(11) NOT NULL COMMENT 'Identificador unico del entrenador',
  `AnosDeExperiencia` int(11) NOT NULL COMMENT 'Años de experiencia como entrenador',
  `Cargo` varchar(30) NOT NULL COMMENT 'Cargo asignado (Ej. Director tecnico, Asistente)',
  `NumeroDeDocumento` int(11) NOT NULL COMMENT 'Documento que relaciona al entrenador con la persona.',
  PRIMARY KEY (`idEntrenadores`,`NumeroDeDocumento`),
  KEY `fk_Entrenadores_Personas1_idx` (`NumeroDeDocumento`),
  CONSTRAINT `fk_Entrenadores_Personas1` FOREIGN KEY (`NumeroDeDocumento`) REFERENCES `personas` (`NumeroDeDocumento`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entrenadores`
--

LOCK TABLES `entrenadores` WRITE;
/*!40000 ALTER TABLE `entrenadores` DISABLE KEYS */;
INSERT INTO `entrenadores` VALUES (100,4,'Fisioterapeuta',1045678901),(101,11,'Director Técnico',1056789012),(102,9,'Preparador Físico',1067890123),(103,7,'Psicólogo Deportivo',1078901234),(104,6,'Asistente Técnico',1089012345),(105,15,'Director Técnico',1090123456),(106,10,'Analista Táctico',1101234567),(107,5,'Preparador Físico',1112345678),(108,13,'Entrenador de Arqueros',1123456789);
/*!40000 ALTER TABLE `entrenadores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entrenadorescategorias`
--

DROP TABLE IF EXISTS `entrenadorescategorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `entrenadorescategorias` (
  `idCategorias` int(11) NOT NULL COMMENT 'Categoria que entrena el entrenador',
  `idEntrenadores` int(11) NOT NULL COMMENT 'Entrenador responsable de la categoria',
  PRIMARY KEY (`idCategorias`,`idEntrenadores`),
  KEY `fk_Categorias_has_Entrenadores_Entrenadores1_idx` (`idEntrenadores`),
  KEY `fk_Categorias_has_Entrenadores_Categorias1_idx` (`idCategorias`),
  CONSTRAINT `fk_Categorias_has_Entrenadores_Categorias1` FOREIGN KEY (`idCategorias`) REFERENCES `categorias` (`idCategorias`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_Categorias_has_Entrenadores_Entrenadores1` FOREIGN KEY (`idEntrenadores`) REFERENCES `entrenadores` (`idEntrenadores`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entrenadorescategorias`
--

LOCK TABLES `entrenadorescategorias` WRITE;
/*!40000 ALTER TABLE `entrenadorescategorias` DISABLE KEYS */;
INSERT INTO `entrenadorescategorias` VALUES (301,101),(302,102),(303,103),(304,104),(305,105),(306,106),(307,107),(308,108),(309,103),(310,104),(311,100),(311,105);
/*!40000 ALTER TABLE `entrenadorescategorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `equipos`
--

DROP TABLE IF EXISTS `equipos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `equipos` (
  `idEquipo` int(11) NOT NULL COMMENT 'Identificador unico del equipo.',
  `NombresEquipos` varchar(25) NOT NULL COMMENT 'Define el nombre de Qulmes y todos sus rivales.\n',
  `CantidadJugadores` int(11) NOT NULL COMMENT 'Cantidad de jugadores que tiene cada equipo',
  `Sub` varchar(10) NOT NULL COMMENT 'Categoria a la que  pertenece cada equipo (ej. sub-20).',
  PRIMARY KEY (`idEquipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipos`
--

LOCK TABLES `equipos` WRITE;
/*!40000 ALTER TABLE `equipos` DISABLE KEYS */;
INSERT INTO `equipos` VALUES (900,'Caimanes Junior',16,'2010'),(901,'Tigres FC',15,'2008'),(902,'Quilmes',15,'2010'),(903,'Furia Urbana',22,'2009'),(904,'Truenos del Este',15,'2014'),(905,'Cóndores FC',16,'2015'),(906,'Toros FC',15,'2008'),(907,'Fénix Azul',25,'2010'),(908,'Quilmes',21,'2011'),(909,'Quilmes',24,'2012'),(910,'Quilmes',22,'2010'),(911,'Quilmes',20,'2006'),(912,'Quilmes',18,'2011'),(913,'Quilmes',21,'2015'),(914,'Quilmes',23,'2013'),(915,'Quilmes',22,'2013'),(916,'Real Andes',22,'2012'),(917,'Quilmes',25,'2010'),(918,'Quilmes',15,'2007'),(919,'Panteras Negras',21,'2006'),(920,'Quilmes',21,'2005'),(921,'Pumas Bogotá',15,'2007'),(922,'Quilmes',19,'2008'),(923,'Quilmes',15,'2008'),(924,'Lobos del Norte',15,'2013'),(925,'Quilmes',24,'2014'),(926,'Quilmes',25,'2011'),(927,'Rayos Capitalinos',20,'2013'),(928,'Quilmes',16,'2013'),(929,'Quilmes',16,'2013'),(930,'Estrellas FC',25,'2014'),(931,'Quilmes',15,'2005'),(932,'Guerreros del Sur',20,'2005'),(933,'Águilas Rojas',23,'2011'),(934,'Quilmes',22,'2005'),(935,'Quilmes',24,'2008'),(936,'Quilmes',21,'2007'),(937,'Atlético Solar',18,'2010'),(938,'Jaguares del Sur',22,'2005'),(939,'Huracanes FC',21,'2011'),(940,'Quilmes',22,'2010'),(941,'Vikingos del Centro',21,'2013'),(942,'Titanes Dorados',18,'2014'),(943,'Quilmes',15,'2008'),(944,'Quilmes',24,'2007'),(945,'Halcones Azules',22,'2014'),(946,'Leones Capital',21,'2011'),(947,'Leones Dorados',17,'2009'),(948,'Dragones Verdes',22,'2011'),(949,'Leopardos Juveniles',23,'2014');
/*!40000 ALTER TABLE `equipos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jugadores`
--

DROP TABLE IF EXISTS `jugadores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jugadores` (
  `idJugadores` int(11) NOT NULL COMMENT 'Pk para identificar cada jugador.',
  `Dorsal` int(11) NOT NULL COMMENT 'Numero en la camisa que tiene cada jugador ',
  `Posicion` varchar(25) NOT NULL COMMENT 'Sitio en el que se ubica en la cancha cada jugador.',
  `NumeroDeDocumento` int(11) NOT NULL COMMENT 'Documento que relaciona al jugador con la persona',
  `idPartido` int(11) NOT NULL COMMENT 'Identificador del partido en el que participo',
  `idCategorias` int(11) NOT NULL COMMENT 'Categoria en la que juega el jugador',
  PRIMARY KEY (`idJugadores`,`NumeroDeDocumento`),
  KEY `fk_Roles_Personas1_idx` (`NumeroDeDocumento`),
  KEY `fk_Roles_Partidos1_idx` (`idPartido`),
  KEY `fk_Jugadores_Categorias1_idx` (`idCategorias`),
  CONSTRAINT `fk_Jugadores_Categorias1` FOREIGN KEY (`idCategorias`) REFERENCES `categorias` (`idCategorias`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_Roles_Partidos1` FOREIGN KEY (`idPartido`) REFERENCES `partidos` (`idPartido`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_Roles_Personas1` FOREIGN KEY (`NumeroDeDocumento`) REFERENCES `personas` (`NumeroDeDocumento`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jugadores`
--

LOCK TABLES `jugadores` WRITE;
/*!40000 ALTER TABLE `jugadores` DISABLE KEYS */;
INSERT INTO `jugadores` VALUES (301,9,'portero',11765432,601,302),(302,10,'volante de recuperacion',12654321,602,303),(303,7,'lateral derecho',13543210,603,304),(304,8,'lateral derecho',14567890,604,305),(305,9,'lateral izquierdo',15432109,605,306),(306,10,'defensa central',16321098,606,307),(307,7,'extremo izquierdo',17210987,607,308),(308,8,'defensa central',18109876,608,309),(309,9,'delantero',19098765,609,310),(310,10,'medio campista',12345678,610,311),(311,7,'portero',13456789,611,301),(312,8,'portero',14567890,612,302),(313,9,'defensa central',15678901,613,303),(314,10,'lateral derecho',16789012,614,304),(315,7,'lateral derecho',17890123,615,305),(316,8,'extremo izquierdo',1012345678,616,306),(317,9,'delantero',18901234,617,307),(318,10,'portero',1023456789,618,308),(319,7,'extremo izquierdo',1034567890,619,309),(320,8,'lateral derecho',19012345,620,310),(321,9,'extremo izquierdo',20123456,621,311),(322,10,'medio campista',21234567,622,301),(323,7,'lateral derecho',22345678,623,302),(324,8,'extremo derecho',23456789,624,303),(325,9,'delantero',24567890,625,304),(326,10,'volante de recuperacion',25678901,626,305),(327,7,'portero',26789012,627,306),(328,8,'lateral izquierdo',27890123,628,307),(329,9,'medio campista',28901234,629,308),(330,10,'volante ofensivo',29012345,630,309),(331,7,'volante de recuperacion',30123456,631,310),(332,8,'lateral izquierdo',31234567,632,311),(333,9,'lateral derecho',32345678,633,301),(334,10,'volante ofensivo',33456789,634,302),(335,7,'defensa central',34567890,635,303),(336,8,'defensa central',35678901,636,304),(337,9,'medio campista',36789012,637,305);
/*!40000 ALTER TABLE `jugadores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partidos`
--

DROP TABLE IF EXISTS `partidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `partidos` (
  `idPartido` int(11) NOT NULL COMMENT 'Identificador unico del partido.',
  `Formacion` varchar(10) NOT NULL COMMENT 'Esquema o alineacion usada en el partido (ej. 4-4-2).',
  `idCronograma` int(11) NOT NULL COMMENT 'Identificador del cronograma al que pertenece el partido.',
  `idCompetencias` int(11) NOT NULL,
  PRIMARY KEY (`idPartido`),
  KEY `fk_Partidos_Cronogramas1_idx` (`idCronograma`),
  KEY `fk_Partidos_Competencias1_idx` (`idCompetencias`),
  CONSTRAINT `fk_Partidos_Competencias1` FOREIGN KEY (`idCompetencias`) REFERENCES `competencias` (`idCompetencias`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_Partidos_Cronogramas1` FOREIGN KEY (`idCronograma`) REFERENCES `cronogramas` (`idCronograma`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partidos`
--

LOCK TABLES `partidos` WRITE;
/*!40000 ALTER TABLE `partidos` DISABLE KEYS */;
INSERT INTO `partidos` VALUES (600,'4-3-3',415,223),(601,'4-3-3',420,206),(602,'4-3-3',437,232),(603,'4-2-1-3',402,205),(604,'4-2-1-3',429,244),(605,'4-3-3',438,202),(606,'4-3-3',435,248),(607,'4-2-1-3',400,207),(608,'4-3-3',408,205),(609,'4-2-1-3',426,222),(610,'4-2-1-3',433,234),(611,'4-3-3',422,241),(612,'4-2-1-3',419,206),(613,'4-2-1-3',411,200),(614,'4-3-3',429,218),(615,'4-2-1-3',435,206),(616,'4-2-1-3',441,210),(617,'4-2-1-3',425,219),(618,'4-2-1-3',412,239),(619,'4-3-3',409,208),(620,'4-3-3',410,248),(621,'4-3-3',426,229),(622,'4-2-1-3',428,220),(623,'4-3-3',400,249),(624,'4-3-3',416,231),(625,'4-2-1-3',415,213),(626,'4-2-1-3',437,228),(627,'4-3-3',402,213),(628,'4-2-1-3',446,214),(629,'4-3-3',428,229),(630,'4-2-1-3',430,243),(631,'4-3-3',407,209),(632,'4-3-3',435,239),(633,'4-3-3',403,236),(634,'4-2-1-3',423,229),(635,'4-3-3',418,232),(636,'4-3-3',442,238),(637,'4-3-3',403,243),(638,'4-2-1-3',403,236),(639,'4-3-3',445,221),(640,'4-3-3',420,230),(641,'4-2-1-3',435,210),(642,'4-3-3',401,241),(643,'4-2-1-3',401,207),(644,'4-3-3',442,248),(645,'4-2-1-3',443,248),(646,'4-3-3',421,228),(647,'4-2-1-3',425,234),(648,'4-3-3',430,222),(649,'4-2-1-3',427,237);
/*!40000 ALTER TABLE `partidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partidosequipos`
--

DROP TABLE IF EXISTS `partidosequipos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `partidosequipos` (
  `idPartido` int(11) NOT NULL COMMENT 'Partido en el que participa el equipo',
  `idEquipo` int(11) NOT NULL COMMENT 'Equipo participante en el partido.',
  `EsLocal` tinyint(4) NOT NULL COMMENT 'Indica si el equipo es local (1) o visitante (0).',
  PRIMARY KEY (`idPartido`,`idEquipo`),
  KEY `fk_Partido_has_Equipo_Equipo1_idx` (`idEquipo`),
  KEY `fk_Partido_has_Equipo_Partido1_idx` (`idPartido`),
  CONSTRAINT `fk_Partido_has_Equipo_Equipo1` FOREIGN KEY (`idEquipo`) REFERENCES `equipos` (`idEquipo`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_Partido_has_Equipo_Partido1` FOREIGN KEY (`idPartido`) REFERENCES `partidos` (`idPartido`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partidosequipos`
--

LOCK TABLES `partidosequipos` WRITE;
/*!40000 ALTER TABLE `partidosequipos` DISABLE KEYS */;
INSERT INTO `partidosequipos` VALUES (600,900,1),(600,901,0),(601,902,1),(601,903,0),(602,904,1),(602,905,0),(603,906,1),(603,907,0),(604,908,1),(604,909,0),(605,910,1),(605,911,0),(606,912,1),(606,913,0),(607,914,1),(607,915,0),(608,916,1),(608,917,0),(609,918,1),(609,919,0),(610,920,1),(610,921,0),(611,922,1),(611,923,0),(612,924,1),(612,925,0),(613,926,1),(613,927,0),(614,928,1),(614,929,0),(615,930,1),(615,931,0),(616,932,1),(616,933,0),(617,934,1),(617,935,0),(618,936,1),(618,937,0),(619,938,1),(619,939,0),(620,940,1),(620,941,0),(621,942,1),(621,943,0),(622,944,1),(622,945,0),(623,946,1),(623,947,0),(624,948,1),(624,949,0);
/*!40000 ALTER TABLE `partidosequipos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personas`
--

DROP TABLE IF EXISTS `personas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personas` (
  `NumeroDeDocumento` int(11) NOT NULL COMMENT 'Muestra el numero de documento de la persona',
  `Nombre1` varchar(30) NOT NULL COMMENT 'Primer nombre de la persona ',
  `Nombre2` varchar(30) NOT NULL COMMENT 'Segundo nombre de la persona ',
  `Apellido1` varchar(30) NOT NULL COMMENT 'Primer apellido de la persona.',
  `Apellido2` varchar(30) NOT NULL COMMENT 'Segundo apellido de la persona.',
  `Genero` varchar(9) NOT NULL COMMENT 'Genero en el que nacio la persona.',
  `Telefono` varchar(10) NOT NULL COMMENT 'Numero telefonico de contacto.',
  `Direccion` varchar(40) NOT NULL COMMENT 'Direccion de residencia de la persona.',
  `FechaDeNacimiento` date NOT NULL COMMENT 'Fecha de nacimiento de la persona',
  `correo` varchar(40) NOT NULL COMMENT 'Correo electronico de la persona',
  `contraseña` varchar(128) NOT NULL COMMENT 'muestra la contraseña de  la persona.\n\n512 bits, 128 caracteres.',
  `TipoDeRol` varchar(13) NOT NULL COMMENT 'Identifica si va a ser Admin, entrenador o jugador.',
  `idTiposDeDocumentos` int(11) NOT NULL COMMENT 'fk de la tabla TiposDeDocumentos para validarle el documento a la persona.',
  PRIMARY KEY (`NumeroDeDocumento`,`idTiposDeDocumentos`),
  UNIQUE KEY `Numero_de_documento_UNIQUE` (`NumeroDeDocumento`),
  UNIQUE KEY `correo_UNIQUE` (`correo`),
  KEY `fk_Persona_TiposDeDocumentos1_idx` (`idTiposDeDocumentos`),
  CONSTRAINT `fk_Persona_TiposDeDocumentos1` FOREIGN KEY (`idTiposDeDocumentos`) REFERENCES `tiposdedocumentos` (`idTiposDeDocumentos`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personas`
--

LOCK TABLES `personas` WRITE;
/*!40000 ALTER TABLE `personas` DISABLE KEYS */;
INSERT INTO `personas` VALUES (11765432,'Santiago','Andrés','Martínez','Castro','Masculino','3045671234','Cl 15 #8-33, Bogota','2007-08-09','santiago.martinez@gmail.com','Ls92qwer','Jugador',2),(12345678,'David','Esteban','Rojas','Pérez','Masculino','3124567890','Cra 25 #10-21, Bogotá','2012-07-01','david.rojas@gmail.com','Tu12lkjm','Jugador',11),(12654321,'Mariana','Isabel','Gómez','Rojas','Femenino','3012345678','Calle 20 #33-77, Bogota','2009-11-05','mariana.gomez@gmail.com','Hd74bnm2','Jugador',3),(13456789,'Laura','Camila','Gómez','Moreno','Femenino','3187654321','Cl 60 #11-10, Bogotá','2009-02-14','laura.gomez@gmail.com','Zx34polq','Jugador',12),(13543210,'Juan','Sebastián','Díaz','Morales','Masculino','3156784321','Av. Caracas #10-22, Bogota','2011-01-23','juan.diaz@gmail.com','Pq82xzv4','Jugador',4),(14567890,'Valeria','Sofía','Romero','Salazar','Femenino','3109876543','Cl 6 #19-12, Bogota','2013-01-17','valeria.romero@gmail.com','Br62mnpo','Jugador',5),(15432109,'Nicolás','David','Herrera','González','Masculino','3161234567','Calle 10 #55-30, Bogota','2014-05-17','nicolas.herrera@gmail.com','As91lkjh','Jugador',6),(15678901,'Isabella','Sofía','Castillo','Ruiz','Femenino','3109871234','Calle 100 #15-20, Bogotá','2006-06-19','isabella.castillo@gmail.com','Jm82qwet','Jugador',14),(16321098,'Juliana','Paola','Torres','Jiménez','Femenino','3194567890','Carrera 8 #29-40, Bogota','2009-09-11','juliana.torres@gmail.com','Xe28zmbn','Jugador',7),(16789012,'Emiliano','José','Salazar','León','Masculino','3156782345','Cra. 40 #22-80, Bogotá','2013-03-09','emiliano.salazar@gmail.com','Vb19zpak','Jugador',15),(17210987,'Samuel','Alejandro','López','Ramírez','Masculino','3123451234','Cl 7 #90-25, Bogota','2006-03-22','samuel.lopez@gmail.com','Tu47qazx','Jugador',8),(17890123,'Sara','Valentina','Cárdenas','Romero','Femenino','3197650123','Cl 30 #12-90, Bogotá','1990-10-12','sara.cardenas@gmail.com','Qw61kjhe','Jugador',16),(18109876,'Camila','Alejandra','Vargas','Ruiz','Femenino','3187654321','Calle 18 #10-18, Bogota','2006-05-13','camila.vargas@gmail.com','Lk90weqe','Jugador',9),(18901234,'Julieta','Alejandra','Peña','Navarro','Femenino','3056789123','Cra. 80 #45-60, Bogotá','1987-04-25','julieta.pena@gmail.com','Hq45lstu','Jugador',18),(19012345,'Samuel','Esteban','Martínez','Rincón','Masculino','3106543210','Cra. 19 #40-88, Bogotá','2011-12-10','samuel.martinez@gmail.com','Kv17nsqe','Jugador',21),(19098765,'Tomás','Eduardo','Castillo','Mendoza','Masculino','3176543210','Cra 9 #40-66, Bogota','2010-05-22','tomas.castillo@gmail.com','Op53vrtn','Jugador',10),(20123456,'Valentina','Andrea','Rodríguez','Pardo','Femenino','3147890123','Cl 84 #15-26, Bogotá','2007-11-02','valentina.rodriguez@gmail.com','Gf92pwlk','Jugador',22),(21234567,'Jerónimo','Daniel','González','Ramírez','Masculino','3153456789','Av. 1 de Mayo #10-45, Bogotá','2012-05-18','jeronimo.gonzalez@gmail.com','Tx63rjew','Jugador',23),(22345678,'Ana','María','Mendoza','Salinas','Femenino','3012347689','Cra. 13 #63-90, Bogotá','2008-01-30','ana.mendoza@gmail.com','Jl46snqp','Jugador',24),(23456789,'Esteban','David','Herrera','Cifuentes','Masculino','3197654321','Calle 77 #80-31, Bogotá','2010-10-15','esteban.herrera@gmail.com','Wm58leut','Jugador',25),(24567890,'Sofía','Natalia','López','Gualteros','Femenino','3121234567','Cra. 23 #45-66, Bogotá','2006-06-06','sofia.lopez@gmail.com','Aq29dzmv','Jugador',26),(25678901,'Emmanuel','Santiago','Castro','Méndez','Masculino','3189988776','Cl 100 #40-77, Bogotá','2009-04-04','emmanuel.castro@gmail.com','Xz81pown','Jugador',27),(26789012,'Mariana','Lucia','Vega','Rodríguez','Femenino','3134455667','Calle 42 #70-30, Bogotá','2007-02-22','mariana.vega@gmail.com','Qm73hkeo','Jugador',28),(27890123,'Daniel','Felipe','Rubio','Acosta','Masculino','3054321987','Cra. 10 #90-17, Bogotá','2011-03-14','daniel.rubio@gmail.com','Zk66tdlv','Jugador',29),(28901234,'Salomé','Isabel','Naranjo','Beltrán','Femenino','3176549870','Av. Las Américas #20-50, Bogotá','2011-11-23','salome.naranjo@gmail.com','Bl95wnqu','Jugador',30),(29012345,'Martín','Alejandro','Paredes','Acuña','Masculino','3101234567','Cl. 16 #22-98, Bogotá','1986-05-03','martin.paredes@gmail.com','Nv12wlqp','Jugador',31),(30123456,'Isaac','Daniel','Londoño','Quintero','Masculino','3122345678','Calle 40 #10-70, Bogotá','2012-06-20','isaac.londono@gmail.com','Kp73nxdq','Jugador',33),(31234567,'Ximena','Alejandra','Ruiz','Vargas','Femenino','3196547890','Cl. 98 #14-10, Bogotá','2010-09-11','ximena.ruiz@gmail.com','Dj59tmsa','Jugador',34),(32345678,'Thiago','Enrique','Blanco','Camargo','Masculino','3119876543','Cra. 65 #23-45, Bogotá','2013-12-07','thiago.blanco@gmail.com','Rl36owqe','Jugador',35),(33456789,'Paulina','Sofía','Ramírez','Paredes','Femenino','3171112233','Av. 1ra #88-66, Bogotá','2008-06-20','paulina.ramirez@gmail.com','Jx67mnbq','Jugador',36),(34567890,'Simón','David','Delgado','Lizarazo','Masculino','3148887766','Calle 10 #55-30, Bogotá','2011-01-09','simon.delgado@gmail.com','Hv45pzlo','Jugador',37),(35678901,'Renata','Michelle','Torres','Sánchez','Femenino','3057654321','Cra. 33 #67-50, Bogotá','2006-10-30','renata.torres@gmail.com','Zm29eyrk','Jugador',38),(36789012,'Emiliano','Jesús','Pérez','Salamanca','Masculino','3189012234','Calle 70 #89-40, Bogotá','1989-09-15','emiliano.perez@gmail.com','Lt63dxwo','Jugador',39),(1012345678,'Andrés','Felipe','Ortega','Gutiérrez','Masculino','3012345678','Cl 48 #11-89, Bogotá','1987-09-03','andres.ortega@gmail.com','Nm34weqp','Jugador',17),(1023456789,'Camilo','Andrés','Molina','Castaño','Masculino','3023459876','Calle 8 #20-30, Bogotá','1985-04-27','camilo.molina@gmail.com','Uz39pdlo','Jugador',19),(1034567890,'Paula','Andrea','Guerrero','Torres','Femenino','3111234567','Cra. 13 #78-45, Bogotá','2008-08-27','paula.guerrero@gmail.com','Wm83aslk','Jugador',20),(1045678901,'Fernanda','Andrea','Patiño','Rincón','Femenino','3159876543','Cra. 50 #91-20, Bogotá','2007-04-17','fernanda.patino@gmail.com','Ur48lktm','Entrenador',32),(1056789012,'Mónica','Carolina','Beltrán','Núñez','Femenino','3165432109','Cra. 45 #21-33, Bogotá','1988-09-26','monica.beltran@gmail.com','Ew77ralk','Entrenador',40),(1067890123,'Sergio','Andrés','Medina','Guzmán','Masculino','3198760011','Calle 55 #12-44, Bogotá','1991-12-08','sergio.medina@gmail.com','Gh38ytwl','Entrenador',41),(1078901234,'Karen','Paola','Niño','Rodríguez','Femenino','3112233445','Cra. 80 #33-90, Bogotá','1986-02-14','karen.nino@gmail.com','Bt71kjpo','Entrenador',42),(1089012345,'Esteban','Alejandro','Gil','Álvarez','Masculino','3100001122','Cl. 19 #45-10, Bogotá','1964-07-19','esteban.gil@gmail.com','Wq53xbla','Entrenador',43),(1090123456,'Natalia','Andrea','Jiménez','Pardo','Femenino','3121113344','Cra. 27 #22-77, Bogotá','1979-10-28','natalia.jimenez@gmail.com','Ez94clrw','Entrenador',44),(1101234567,'Melany','Sofía','Salas','Villamil','Femenino','3044567890','Cl. 73 #9-18, Bogotá','1987-01-10','melany.salas@gmail.com','Tk67ljwa','Entrenador',46),(1112345678,'Duván','Felipe','Rodríguez','Amaya','Masculino','3076543210','Av. 19 #100-25, Bogotá','1980-09-04','duvan.rodriguez@gmail.com','Vy35pwko','Entrenador',47),(1123456789,'Paula','Juliana','Suárez','Fonseca','Femenino','3187765544','Cra. 6 #21-19, Bogotá','1978-11-25','paula.suarez@gmail.com','Ms29tudv','Entrenador',49),(2000012345,'Julien','Rafael','Ortega','Rojas','Masculino','3160099887','Calle 12B #35-80, Bogotá','1983-06-28','julien.ortega@gmail.com','Rm86fdke','Administrador',45),(2000023456,'Thiago','Martín','González','Del Río','Masculino','3099876543','Calle 65 #44-22, Bogotá','1990-05-15','thiago.gonzalez@gmail.com','Oe91kzru','Administrador',48),(2000034567,'Leonardo','Andrés','Carvajal','Bernal','Masculino','3134433221','Cl. 88 #11-30, Bogotá','1978-11-25','leonardo.carvajal@gmail.com','Qx41ncpz','Administrador',50);
/*!40000 ALTER TABLE `personas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rendimientospartidos`
--

DROP TABLE IF EXISTS `rendimientospartidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rendimientospartidos` (
  `Id_RendimientosP` int(11) NOT NULL COMMENT 'Identificador unico del rendimiento en el partido',
  `Goles` int(11) DEFAULT NULL COMMENT 'Numero de goles marcados.',
  `GolesDeCabeza` int(11) DEFAULT NULL COMMENT 'Goles marcados con la cabeza.',
  `MinutosJugados` int(11) DEFAULT NULL COMMENT 'Total de minutos jugados por el jugador.',
  `Asistencias` int(11) DEFAULT NULL COMMENT 'Cantidad de asistencias realizadas.',
  `TirosApuerta` int(11) DEFAULT NULL COMMENT 'Numero de tiros realizados a porteria.',
  `TarjetasRojas` int(11) DEFAULT NULL COMMENT 'Cantidad de tarjetas rojas recibidas.',
  `TarjetasAmarillas` int(11) DEFAULT NULL COMMENT 'Cantidad de tarjetas amarillas recibidas.',
  `FuerasDeLugar` int(11) DEFAULT NULL COMMENT 'Cantidad de veces en fuera de lugar.',
  `ArcoEnCero` int(11) DEFAULT NULL COMMENT 'Indica si el arquero mantuvo su arco en cero.',
  `idPartido` int(11) NOT NULL COMMENT 'Partido al que corresponde el rendimiento.',
  `idJugadores` int(11) NOT NULL,
  PRIMARY KEY (`Id_RendimientosP`),
  KEY `fk_Estadisticas_Partido1_idx` (`idPartido`),
  KEY `fk_RendimientosPartidos_Jugadores1_idx` (`idJugadores`),
  CONSTRAINT `fk_Estadisticas_Partido1` FOREIGN KEY (`idPartido`) REFERENCES `partidos` (`idPartido`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_RendimientosPartidos_Jugadores1` FOREIGN KEY (`idJugadores`) REFERENCES `jugadores` (`idJugadores`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rendimientospartidos`
--

LOCK TABLES `rendimientospartidos` WRITE;
/*!40000 ALTER TABLE `rendimientospartidos` DISABLE KEYS */;
INSERT INTO `rendimientospartidos` VALUES (700,15,0,1688,19,22,6,14,10,5,600,301),(701,25,12,577,4,31,3,10,7,0,601,302),(702,42,13,1100,6,7,0,38,5,0,602,303),(703,45,5,1641,24,29,0,11,11,0,603,304),(704,26,0,1042,12,44,10,36,12,0,604,305),(705,13,2,1979,2,8,7,24,3,0,605,306),(706,16,12,1589,16,35,7,5,13,0,606,307),(707,21,7,515,27,22,5,29,15,0,607,308),(708,18,3,1315,20,32,8,3,13,0,608,309),(709,48,13,1465,1,6,6,24,14,0,609,310),(710,31,14,1770,17,6,0,34,10,23,610,311),(711,25,10,1428,24,44,9,37,15,2,611,312),(712,28,0,744,0,16,7,27,10,0,612,313),(713,16,12,1509,15,2,0,8,5,0,613,314),(714,38,15,856,3,0,8,32,3,0,614,315),(715,45,2,314,10,21,7,37,6,0,615,316),(716,20,2,833,25,32,2,39,11,0,616,317),(717,6,11,1620,27,36,0,17,1,33,617,318),(718,13,15,1395,6,17,3,1,15,0,618,319),(719,9,4,447,18,20,2,26,13,0,619,320),(720,2,0,1379,30,20,9,11,12,0,620,321),(721,43,0,1098,11,7,7,28,10,0,621,322),(722,12,3,986,3,31,10,35,2,0,622,323),(723,15,13,1489,14,39,2,10,2,0,623,324),(724,16,11,447,8,21,6,10,3,0,624,325),(725,0,10,672,19,0,8,23,15,0,625,326),(726,34,9,1147,5,40,1,30,10,12,626,327),(727,43,3,1161,30,34,6,17,10,0,627,328),(728,5,6,1088,21,25,8,4,4,0,628,329),(729,46,0,1616,14,0,5,14,11,0,629,330),(730,10,12,494,25,50,10,9,2,0,630,331),(731,2,8,704,2,23,2,7,8,0,631,332),(732,28,9,1066,30,19,8,30,11,0,632,333),(733,28,10,1379,0,26,9,3,13,0,633,334),(734,24,14,1966,24,6,1,16,15,0,634,335),(735,30,1,788,7,38,6,7,9,0,635,336),(736,24,4,803,5,2,1,10,8,0,636,337);
/*!40000 ALTER TABLE `rendimientospartidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resultados`
--

DROP TABLE IF EXISTS `resultados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resultados` (
  `idDetalles` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico del resultado.',
  `Marcador` varchar(10) NOT NULL COMMENT 'Resultado final del partido (ej. 3-1).',
  `PuntosObtenidos` int(11) NOT NULL COMMENT 'Cantidad de puntos ganados por el equipo.',
  `Observacion` varchar(100) DEFAULT NULL COMMENT 'Comentarios adicionales sobre el resultado',
  `idPartido` int(11) NOT NULL COMMENT 'Partido al que corresponde el resultado',
  PRIMARY KEY (`idDetalles`,`idPartido`),
  KEY `fk_Resultado_Partidos1_idx` (`idPartido`),
  CONSTRAINT `fk_Resultado_Partidos1` FOREIGN KEY (`idPartido`) REFERENCES `partidos` (`idPartido`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2060 DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resultados`
--

LOCK TABLES `resultados` WRITE;
/*!40000 ALTER TABLE `resultados` DISABLE KEYS */;
INSERT INTO `resultados` VALUES (2010,'0-0 draw',1,'',600),(2011,'1-0 win',3,'Interrupción por hinchas',601),(2012,'0-1 lost',0,'',602),(2013,'0-1 lost',0,'',603),(2014,'1-1 draw',1,'',604),(2015,'2-2 draw',1,'Retraso por lluvia',605),(2016,'2-1 win',3,'Retraso por lluvia',606),(2017,'2-1 win',3,'',607),(2018,'1-3 lost',0,'',608),(2019,'0-0 draw',1,'',609),(2020,'1-3 lost',0,'Problemas con el árbitro',610),(2021,'1-1 draw',1,'Problemas con el árbitro',611),(2022,'2-3 lost',0,'',612),(2023,'1-0 win',3,'',613),(2024,'2-3 lost',0,'Problemas con el árbitro',614),(2025,'1-3 lost',0,'',615),(2026,'0-0 draw',1,'',616),(2027,'4-2 win',3,'',617),(2028,'2-3 lost',0,'Interrupción por hinchas',618),(2029,'3-0 lost',0,'Partido detenido temporalmente',619),(2030,'4-2 win',3,'',620),(2031,'3-0 lost',0,'',621),(2032,'2-2 draw',1,'',622),(2033,'2-1 win',3,'',623),(2034,'0-1 lost',0,'',624),(2035,'2-1 win',3,'',625),(2036,'5-0 win',3,'',626),(2037,'3-0 lost',0,'',627),(2038,'2-2 draw',1,'Problemas con el árbitro',628),(2039,'5-0 win',3,'',629),(2040,'1-0 win',3,'',630),(2041,'1-1 draw',1,'',631),(2042,'0-1 lost',0,'',632),(2043,'3-0 lost',0,'',633),(2044,'1-1 draw',1,'',634),(2045,'1-1 draw',1,'Interrupción por hinchas',635),(2046,'0-0 draw',1,'Lesión de jugador',636),(2047,'1-3 lost',0,'',637),(2048,'2-1 win',3,'',638),(2049,'5-0 win',3,'',639),(2050,'3-3 draw',1,'',640),(2051,'1-3 lost',0,'',641),(2052,'3-3 draw',1,'Fallo en la iluminación',642),(2053,'2-2 draw',1,'',643),(2054,'4-2 win',3,'',644),(2055,'3-3 draw',1,'Lesión de jugador',645),(2056,'1-0 win',3,'',646),(2057,'0-0 draw',1,'',647),(2058,'3-0 lost',0,'Problemas con el árbitro',648),(2059,'2-3 lost',0,'',649);
/*!40000 ALTER TABLE `resultados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tiposdedocumentos`
--

DROP TABLE IF EXISTS `tiposdedocumentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tiposdedocumentos` (
  `idTiposDeDocumentos` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Pk que muestra el id de los tipos de domento.',
  `Descripcion` varchar(45) NOT NULL COMMENT 'Muestra textualmente el tipo del documento.',
  PRIMARY KEY (`idTiposDeDocumentos`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tiposdedocumentos`
--

LOCK TABLES `tiposdedocumentos` WRITE;
/*!40000 ALTER TABLE `tiposdedocumentos` DISABLE KEYS */;
INSERT INTO `tiposdedocumentos` VALUES (1,'Tarjeta de identidad'),(2,'Tarjeta de identidad'),(3,'Tarjeta de identidad'),(4,'Tarjeta de identidad'),(5,'Tarjeta de identidad'),(6,'Tarjeta de identidad'),(7,'Cedula de ciudadania'),(8,'Cedula de ciudadania'),(9,'Tarjeta de identidad'),(10,'Tarjeta de identidad'),(11,'Tarjeta de identidad'),(12,'Tarjeta de identidad'),(13,'Tarjeta de identidad'),(14,'Tarjeta de identidad'),(15,'Tarjeta de identidad'),(16,'Tarjeta de identidad'),(17,'Cedula de ciudadania'),(18,'Tarjeta de identidad'),(19,'Cedula de ciudadania'),(20,'Cedula de ciudadania'),(21,'Tarjeta de identidad'),(22,'Tarjeta de identidad'),(23,'Tarjeta de identidad'),(24,'Tarjeta de identidad'),(25,'Tarjeta de identidad'),(26,'Tarjeta de identidad'),(27,'Tarjeta de identidad'),(28,'Tarjeta de identidad'),(29,'Tarjeta de identidad'),(30,'Tarjeta de identidad'),(31,'Tarjeta de identidad'),(32,'Cedula de ciudadania'),(33,'Tarjeta de identidad'),(34,'Tarjeta de identidad'),(35,'Tarjeta de identidad'),(36,'Tarjeta de identidad'),(37,'Tarjeta de identidad'),(38,'Tarjeta de identidad'),(39,'Tarjeta de identidad'),(40,'Cedula de ciudadania'),(41,'Cedula de ciudadania'),(42,'Cedula de ciudadania'),(43,'Cedula de ciudadania'),(44,'Cedula de ciudadania'),(45,'Cedula de extranjeria'),(46,'Cedula de ciudadania'),(47,'Cedula de ciudadania'),(48,'Cedula de extranjeria'),(49,'Cedula de ciudadania'),(50,'Cedula de extranjeria');
/*!40000 ALTER TABLE `tiposdedocumentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'scord'
--

--
-- Dumping routines for database 'scord'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-07-06 19:02:32
