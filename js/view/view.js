'use strict'

function obtenerRutaIcono(nombreProducto) {
    if (!nombreProducto) return 'images/icons/default.svg';
    const primeraPalabra = nombreProducto.trim().split(/\s+/)[0].toLowerCase();
    const clave = primeraPalabra
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .replace(/[^a-z0-9_-]/g, '');

    return clave ? `images/icons/${clave}.svg` : 'images/icons/default.svg';
}

//Mostar productos en el modal 
function mostrarProductos(productos) {
    const contenedor = $("#contenedor-productos");
    contenedor.empty();
    for (let i = 0; i < productos.length; i++) {
        const producto = productos[i];
        const idIcono = `icono-producto-${producto.id ?? i}`;
        const rutaIcono = obtenerRutaIcono(producto.nombre);

        const tarjeta = $(`
            <article class="tarjeta-producto">
                <div class="ficha-top-bar">
                    <span class="detail-category">${producto.categoria}</span>
                </div>
                <div class="ficha-titulo-fila">
                    <div id="${idIcono}" class="icono-producto icono-titulo" aria-hidden="true">
                        <img src="${rutaIcono}"
                            alt=""
                            loading="lazy"
                            onerror="this.onerror=null;this.src='https://xabilasa.com/kmzero/images/icons/default.svg';">
                    </div>
                    <h3>${producto.nombre}</h3>
                </div>
                <div class="info-producto">
                    <p class="productor"><strong>Productor:</strong> ${producto.productor}</p>
                    <p class="productor"><strong>Zona:</strong> ${producto.zona}</p>
                </div>
            </article>
        `);
        tarjeta.data("producto", producto);
        contenedor.append(tarjeta);
    }
}

// Colorear la barra para ofrecer referencia visual de proximidad
function obtenerColorBarra(producto, distanciaMaxima, codigoPostal) {
    if (esMismaProvincia(producto.zona, codigoPostal)) {
        return "same-province";
    } else if (producto.distancia_calculada_km === distanciaMaxima) {
        return "farthest";
    } else if (producto.distancia_calculada_km < 125) {
        return "nearby";
    } else {
        return "other-province";
    }
}

//Mostrar gráfica comparativa entre productos similares
function mostrarGraficaComparativa(productos, codigoPostal) {
    const $contenedor = $("#contenedor-grafica");
    $contenedor.empty();
    if (!productos || productos.length === 0) {
        $contenedor.html(
            '<p class="placeholder-text">No hay productos para comparar.</p>'
        );
        return;
    }

    // Obtener la distancia máxima entre provincias diferentes
    let distanciaMaxima = 0;
    for (let i = 0; i < productos.length; i++) {
        if (!esMismaProvincia(productos[i].zona, codigoPostal) &&
            productos[i].distancia_calculada_km !== null &&
            productos[i].distancia_calculada_km > distanciaMaxima) {
            distanciaMaxima = productos[i].distancia_calculada_km;
        }
    }

    // Crear una barra por cada productor.
    for (let i = 0; i < productos.length; i++) {
        const producto = productos[i];
        const distancia = producto.distancia_calculada_km;
        let porcentaje = 0;
        if (distanciaMaxima > 0 && distancia !== null) {
            porcentaje = (distancia / distanciaMaxima) * 100;
        }
        let color = obtenerColorBarra(producto, distanciaMaxima, codigoPostal);
        const $fila = $("<div></div>").addClass("chart-row");
        const $nombre = $("<p></p>")
            .addClass("chart-product-name")
            .text(producto.nombre + " - " + producto.zona);
        const $barraFondo = $("<div></div>").addClass("chart-bar-background");
        const $barra = $("<div></div>")
            .addClass("chart-bar")
            .addClass(color)
            .css("width", porcentaje + "%");
        const $distancia = $("<span></span>")
            .addClass("chart-distance")
            .text(distancia !== null ? distancia.toFixed(1) + " km" : "Distancia no disponible");
        $barraFondo.append($barra);
        $fila.append($nombre, $barraFondo, $distancia);
        $contenedor.append($fila);
    }
}

// Función que construte la tabla comparativa de productos similares
function mostrarTablaComparativa(productos) {
    const contenedor = $("#contenedor-tabla");
    contenedor.empty();
    let tabla = `
        <table class="tabla-comparativa">
            <thead>
                <tr>
                    <th>Producto</th>
                    <th>Productor</th>
                    <th>Procedencia</th>
                    <th>Distancia estimada (km)</th>
                </tr>
            </thead>
            <tbody>
    `;
    for (let i = 0; i < productos.length; i++) {
        const producto = productos[i];
        tabla += `
            <tr>
                <td>${producto.nombre}</td>
                <td>${producto.productor}</td>
                <td>${producto.zona}</td>
                <td>${Number(producto.distancia_calculada_km).toFixed(2)}</td>
            </tr>
        `;
    }
    tabla += `
            </tbody>
        </table>
    `;
    contenedor.append(tabla);
}

// Funcion para construir ficha de producto en el modal
function mostrarDetalleProducto(producto) {
    const $contenedor = $("#detalle-producto");
    $contenedor.empty();
    const $titulo = $("<h1></h1>").text(producto.nombre);
    const $producto = $("<section></section>").addClass("detalle-seccion");
    $producto.append("<h2>Información del producto</h2>");
    $producto.append(
        $("<p></p>").text("Categoría: " + (producto.categoria || "No disponible"))
    );
    const $productor = $("<section></section>").addClass("detalle-seccion");
    $productor.append("<h2>Información del productor</h2>");
    $productor.append(
        $("<p></p>").text("Productor: " + (producto.productor || "No disponible")),
        $("<p></p>").text("Zona: " + (producto.zona || "No disponible")),
        $("<p></p>").text("Código postal: " + (producto.codigo_postal || "No disponible"))
    );
    $contenedor.append($titulo, $producto, $productor);
}