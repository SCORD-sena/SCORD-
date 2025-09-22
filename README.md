# SCORD

Sistema de información deportivo para la escuela **Quilmes FC**, desarrollado con **React** y **Laravel**.  
Permite la gestión de jugadores, entrenadores y administradores, además de la recolección y consulta de estadísticas deportivas para apoyar el proceso de formación.

---

## Características
- Registro y administración de jugadores, entrenadores y administradores.
- Recolección y almacenamiento de estadísticas deportivas.
- Consultas y reportes de rendimiento.
- Plataforma web centralizada para la comunicación deportiva.
- Enfoque en la formación y seguimiento de jugadores.

---

## Tecnologías usadas
- [React](https://react.dev/) – Frontend
- [Laravel](https://laravel.com/) – Backend
- [MySQL](https://www.mysql.com/) – Base de datos
- [PHP](https://www.php.net/) – Lenguaje de backend
- [JavaScript](https://developer.mozilla.org/docs/Web/JavaScript) – Lenguaje de frontend

---

## Instalación

### Clonar el repositorio
```bash
git clone https://github.com/usuario/scord.git

### Configurar el BackEnd (Laravel)

cd backend
composer install
cp .env.scord .env
php artisan key:generate
php artisan migrate

### Configurar el FrontEnd (React)

cd frontend
npm install


### Levantar el servidor BackEnd

php artisan serve

### Levantar el servidor FrontEnd

npm start
