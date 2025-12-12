import { BrowserRouter, Routes, Route } from "react-router-dom";
//Admin
import InicioAdmin from "./pages/Admin/InicioAdmin";
import CrEntrenadorAdmin from "./pages/Admin/CrEntrenadorAdmin";
import PerfilJugadorAdmin from "./pages/Admin/PerfilJugadorAdmin";
import PerfilEntrenadorAdmin from "./pages/Admin/PerfilEntrenadorAdmin";
import EstJugadorAdmin from "./pages/Admin/EstJugadorAdmin";
import AgregarJugador from "./pages/Admin/AgregarJugador";
import EditarJugador from "./pages/Admin/EditarJugador";
import AgregarEntrenador from "./pages/Admin/AgregarEntrenador";
import AgregarEstadisticas from "./pages/Admin/AgregarEstadisticas";
import EditarEntrenador from "./pages/Admin/EditarEntrenador";
import EstadisticasJugador from "./pages/Admin/EstadisticasJugador";
import EditarEstadisticas from "./pages/Admin/EditarEstadisticas";
//Entrenador
import InicioEntrenador from "./pages/Entrenador/InicioEntrenador";
import EstJugador from "./pages/Entrenador/EstJugador";
import EditarEst from "./pages/Entrenador/EditarEst";
import AgregarEst from "./pages/Entrenador/AgregarEst";
import CrEntrenador from "./pages/Entrenador/CrEntrenador";
import Estadisticas from "./pages/Entrenador/Estadisticas";
import EstJugadorEntrenador from "./pages/Entrenador/EstJugadorEntrenador";
import EqEntrenador from "./pages/Entrenador/EqEntrenador";
import PerfilJugEntre from "./pages/Entrenador/PerfilJugEntre";
//Jugador
import InicioJugador from "./pages/Jugador/InicioJugador";
import CrJugador from "./pages/Jugador/CrJugador";
import EqJugador from "./pages/Jugador/EqJugador";
import JugEstadisticas from "./pages/Jugador/JugEstadisticas";
//Otros
import CerrarSesion from "./pages/CerrarSesion";
import Index from "./pages/Index";
import Login from "./pages/Login";


function App() {
  return (
      <BrowserRouter>
      <Routes>
        <Route path="/CerrarSesion" element={<CerrarSesion/>} />
        <Route path="/Index" element={<Index/>} />
        <Route path="/Login" element={<Login/>} />
        

        {/* ADMIN */}
        <Route path="/InicioAdmin" element={<InicioAdmin />} />
        <Route path="/EditarJugador" element={<EditarJugador />}/>
        <Route path="/CrEntrenadorAdmin" element={<CrEntrenadorAdmin />} />
        <Route path="/PerfilJugadorAdmin" element={<PerfilJugadorAdmin />} />
        <Route path="/PerfilEntrenadorAdmin" element={<PerfilEntrenadorAdmin />} />
        <Route path="/EstJugadorAdmin" element={<EstJugadorAdmin />} />
        <Route path="/AgregarJugador" element={<AgregarJugador />} /> 
        <Route path="/AgregarEntrenador" element={<AgregarEntrenador />}/>
        <Route path="/EditarEntrenador" element={<EditarEntrenador/>}/>
        <Route path="/EstadisticasJugador" element={<EstadisticasJugador/>} />
        <Route path="/AgregarEstadisticas" element={<AgregarEstadisticas/>}/>
        <Route path="/EditarEstadisticas" element={<EditarEstadisticas/>}/>
        {/* ENTRENADOR */}
        <Route path="/InicioEntrenador" element={<InicioEntrenador/>} />
        <Route path="/CrEntrenador" element={<CrEntrenador/>} />
        <Route path="/EstJugador" element={<EstJugador/>}/>
        <Route path="/EditarEst" element={<EditarEst/>}/>
        <Route path="/AgregarEst" element={<AgregarEst/>}/>
        <Route path="/PerfilJugEntre" element={<PerfilJugEntre/>} />
        <Route path="/EstJugadorEntrenador" element={<EstJugadorEntrenador/>} />
        <Route path="/EqEntrenador" element={<EqEntrenador/>}/>
        <Route path="/Estadisticas" element={<Estadisticas/>} />
      
        {/* JUGADOR */}
        <Route path="/InicioJugador" element={<InicioJugador/>} />
        <Route path="/EqJugador" element={<EqJugador/>} />
        <Route path="/CrJugador" element={<CrJugador/>} />
        <Route path="/JugEstadisticas" element={<JugEstadisticas/>} />
        
        
      </Routes>
    </BrowserRouter>
  );
}

export default App;
