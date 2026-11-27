$(document).ready(function () {
    const producto = recuperarProductoSeleccionado();

    if (producto) {
        mostrarDetalleProducto(producto);
    } else {
        $("#detalle-producto").text(
            "No se ha podido recuperar la información del producto."
        );
    }
});
