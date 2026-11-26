
"use strict";

// Guardar los criterios de búsqueda
function guardarBusqueda(codigoPostal, categoria) {
    localStorage.setItem("kmzero_cp", codigoPostal);
    localStorage.setItem("kmzero_categoria", categoria);
}

// Recuperar los criterios de búsqueda
function recuperarBusqueda() {
    return {
        codigoPostal: localStorage.getItem("kmzero_cp") || "",
        categoria: localStorage.getItem("kmzero_categoria") || "todos"
    };
}

// Rellenar el formulario con los criterios guardados
function inicializarFormulario() {
    const busqueda = recuperarBusqueda();
    $("#input-cp").val(busqueda.codigoPostal);
    $("#select-categoria").val(busqueda.categoria);
}