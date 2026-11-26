'use strict'

// Llamada a la api para comprobar si hay productos nuevos sin icono
$(function () {
    fetch('https://xabilasa.com/kmzero/api/iconos.php?sync=1').catch(function () {});
});

//Inicio de la aplicación
$(document).ready(function(){
    iniciarAplicacion();
});