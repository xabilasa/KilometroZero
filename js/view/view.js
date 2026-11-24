'use strict'

function mostrarProductos(productos){
    const contenedor = $("#contenedor-productos");
    contenedor.empty();
    for (let i = 0; i < productos.length; i++) {
        const producto = productos[i];
        const tarjeta = `
            <article class="tarjeta-producto">
                <h3>${producto.nombre}</h3>
                <p>${producto.categoria}</p>
                <p>Productor: ${producto.productor}</p>
                <p>Zona: ${producto.zona}</p>
            </article>`;
        contenedor.append(tarjeta);
    }
}