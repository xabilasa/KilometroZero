'use strict'

let catalogoProductos = [];
async function iniciarAplicacion(){
    try{
        catalogoProductos = await consultarProductos();
        // mostrarProductos(catalogoProductos);
    } catch (error){
        console.error('Error al iniciar la aplicación:', error);
    }
    // Después de cargar el catálogo hacemos que esté disponible el buscador de productos
    $("#form-busqueda").on("submit", async function(event) {
        event.preventDefault();
        const codigoPostal = $("#input-cp").val();
        const categoria = $("#select-categoria").val();
                const provincia = obtenerCapitalPorCP(codigoPostal);
        if (!provincia){
            console.error("Código postal no válido");
            return;
        }
        // guardar criterios del formulario en localStorage
        guardarBusqueda(codigoPostal, categoria);
        const productosFiltrados = filtrarPorCategoria(catalogoProductos, categoria);
        mostrarProductos(productosFiltrados);
        const coordenadasDestino = await obtenerCoordenadasCP(codigoPostal);
        let latDest = coordenadasDestino.lat;
        let lonDest = coordenadasDestino.lon;
        let latCapiDest = provincia.capitalCP.lat;
        let lonCapiDest = provincia.capitalCP.lon;
        
        for (let i = 0; i < productosFiltrados.length; i++){
            let provinciaOri = obtenerProvinciaPorZona(productosFiltrados[i].zona);
            if (provinciaOri) {
                let latCapiOr = Number(provinciaOri.capitalCP.lat);
                let lonCapiOr = Number(provinciaOri.capitalCP.lon);
                let latOri = Number(productosFiltrados[i].latitud);
                let lonOri = Number(productosFiltrados[i].longitud);
                productosFiltrados[i].distancia_calculada_km = calcularDistanciaLogistica (latOri, lonOri, latCapiOr, lonCapiOr, latCapiDest, lonCapiDest, latDest, lonDest);
                console.log(
                    productosFiltrados[i].nombre,
                    productosFiltrados[i].zona,
                    productosFiltrados[i].distancia_calculada_km
                );
            } else {    
                productosFiltrados[i].distancia_calculada_km = null;
                console.error("No se encuentra la provincia:", productosFiltrados[i].zona);
            }
        }
        // Mostrar los productos ordenados por distancia al origen (Cp aportado) y mostrar la tabla comparativa
        const productosOrdenados = ordenarPorNombreYDistancia(productosFiltrados);
        mostrarProductos(productosOrdenados);
        if ($("#contenedor-tabla").length) {
            mostrarTablaComparativa(productosOrdenados);
        }

        // Agrupar productos con más de un productor para comparativa
        const productosComparables = obtenerProductosComparables(productosOrdenados);


        function cargarSelectorProductos() {
            const $select = $("#select-producto");
            $select.empty();
            if (!productosComparables || productosComparables.length === 0) {
                $select.append(
                    '<option value="">No hay productos repetidos para comparar</option>'
                ).prop("disabled", true);

                return;
            }
            $select.append('<option value="">Selecciona un producto...</option>');
            productosComparables.forEach(grupo => {
                const nombreProducto = grupo.nombreBase;

                $select.append(
                    $("<option></option>")
                        .val(nombreProducto)
                        .text(nombreProducto)
                );
            });

            $select.prop("disabled", false);
        }

        cargarSelectorProductos();

        $("#select-producto").off("change").on("change", function() {
        const nombreSeleccionado = $(this).val();
        if (!nombreSeleccionado) {
            $("#contenedor-grafica").empty().html(
                '<p class="placeholder-text">Selecciona un producto para visualizar sus productores.</p>'
            );
            return;
        }

    const grupoSeleccionado = productosComparables.find(
        grupo => grupo.nombreBase === nombreSeleccionado
    );

    if (grupoSeleccionado) {
        mostrarGraficaComparativa(
            grupoSeleccionado.productos,
            codigoPostal
        );
    }
});

    });
    // Recuperar los criterios guardados en localStorage y rellenar formulario
    const busqueda = recuperarBusqueda();
    inicializarFormulario();
    // Si existe un CP guardado, ejecutar automáticamente la búsqueda
    if (busqueda.codigoPostal) {
        $("#form-busqueda").trigger("submit");
    }

}

//Obtener rutas absolutas al hosting con la api de iconos y los iconos
const BASE_URL_HOSTING = 'https://xabilasa.com/kmzero';
function obtenerRutaIcono(nombreProducto) {
    if (!nombreProducto) return `${BASE_URL_HOSTING}/images/icons/default.svg`;
    const primeraPalabra = nombreProducto.trim().split(/\s+/)[0].toLowerCase();
    const clave = primeraPalabra
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .replace(/[^a-z0-9_-]/g, '');

    return clave
        ? `${BASE_URL_HOSTING}/images/icons/${clave}.svg`
        : `${BASE_URL_HOSTING}/images/icons/default.svg`;
}