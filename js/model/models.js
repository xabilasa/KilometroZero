'use strict'

async function consultarProductos(){
    const apiURL = "https://xabilasa.com/kmzero/api/api.php";
    try{
        const respuesta = await fetch (apiURL);
        if (!respuesta.ok) {
            throw new Error(`Error HTTP: ${respuesta.status}`);
        }
        const datos = await respuesta.json();
        return datos;
    } catch (error) {
        console.error ('Ha habido un problema con la petición:', error);
        throw error;
    }
}

//Obtener coordenadas de un CP utilizando API cartociudad.es
async function obtenerCoordenadasCP(codigoPostal){
    const apiURL = "https://www.cartociudad.es/geocoder/api/geocoder/find?q=" + codigoPostal;

    try {
        const respuesta = await fetch(apiURL);

        if (!respuesta.ok){
            throw new Error("Error HTTP: " + respuesta.status);
        }

        const datos = await respuesta.json();
        const localizaCP = (lat, lon) => ({lat, lon}); // Creo un objeto para pasar coordenadas
        if (datos.lat == null || datos.lng == null){
            console.error("datos de ubicación inválidos");
        } else {
            return localizaCP(datos.lat, datos.lng)
        }

    } catch (error) {
        console.error("Error al consultar CartoCiudad:", error);
        throw error;
    }
}

//Función para calcular una distancia entre dos puntos considerando currvatura terraquea
function calcularDistancia(lat1, lon1, lat2, lon2){
    const rTierra =  6371;
    //Convertir coordenadas a radianes
    lat1 = lat1 * Math.PI / 180;
    lon1 = lon1 * Math.PI / 180;
    lat2 = lat2 * Math.PI / 180;
    lon2 = lon2 * Math.PI / 180;

    let difLat = Math.abs(lat1 - lat2);
    let difLon = Math.abs(lon1 - lon2);
    
    // Calcula Haversine para considerar la curvatura de la tierra en la distancia
    let a = Math.sin(difLat / 2) ** 2 + 
            Math.cos(lat2) * Math.cos(lat1) * 
            Math.sin(difLon / 2) ** 2;

    let c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    let distancia = rTierra * c;

    return distancia;
}

// Función para calcular distancias logísticas. Pedimos latitud y longitud de 4 puntos: 
// Tramo 1: Productor => Capital de su Provincia
// Tramo 2: Capital Productor => Capital Provincia Usuario
// Tramo 3: Capital Usuario => Usuario 
function calcularDistanciaLogistica (latProd, lonProd, latCapiOr, lonCapiOr, latCapiDest, lonCapiDest, latDest, lonDest){
    const tramo1 = calcularDistancia (latProd, lonProd, latCapiOr, lonCapiOr);
    const tramo2 = calcularDistancia (latCapiOr, lonCapiOr, latCapiDest, lonCapiDest);
    const tramo3 = calcularDistancia (latCapiDest, lonCapiDest, latDest, lonDest);

    //La suna total de las distancias se multiplica por el factor de tortuosidad de carreteras ~ 1.3
    return (tramo1 + tramo2 + tramo3)  * 1.3;
}

// Función que devuelve el objeto Provincia a partir de los dos primeros dígitos del CP proporcionado
function obtenerCapitalPorCP(codigoPostal){
    const cpValido = (codigoPostal) => /^\d{5}$/.test(codigoPostal);
    if (!cpValido(codigoPostal)){
        return null;
    }
    const codigoProvincia = codigoPostal.substring(0, 2);

    for (let  i=0; i<Provincias.length; i++){
        let codProvincia = Provincias[i].cp;
        if (codigoProvincia === codProvincia){
            return Provincias[i];
        }
    }
    return null;
}

// Obtener provincia por zona del productor
function obtenerProvinciaPorZona(zona) {
    const partes = zona.split(/[\/,]/);

    for (let i = 0; i < partes.length; i++) {
        const nombre = partes[i].trim();

        for (let j = 0; j < Provincias.length; j++) {
            if (Provincias[j].nombre === nombre) {
                return Provincias[j];
            }
        }
    }

    return null;
}

//Filtrar productos por categoría
function filtrarPorCategoria (productos, categoria){
    if (categoria === "todos"){
        return productos;
    }
    let productosFiltrados = [];
    for (let i = 0; i < productos.length; i++){
        if(productos[i].categoria === categoria){
            productosFiltrados.push(productos[i]);
        }
    }
    return productosFiltrados;
}

// Ordenar por distancia para utilizar con productos similares y comparar
function ordenarPorDistancia(productos) {
    return productos.sort(function(a, b) {
        return a.distancia_calculada_km - b.distancia_calculada_km;
    });
}

//Obtener nombre de productos (primeras palabra) para comparaciones
function obtenerNombreBase(nombre) {
    const palabras = nombre.split(" ");
    return palabras[0];
}

// Función de ordenación de productos para la tabla comparativa
function ordenarPorNombreYDistancia(productos) {
    return productos.sort(function(a, b) {
        const nombreA = obtenerNombreBase(a.nombre).toLowerCase();
        const nombreB = obtenerNombreBase(b.nombre).toLowerCase();

        if (nombreA < nombreB) {
            return -1;
        }

        if (nombreA > nombreB) {
            return 1;
        }

        return a.distancia_calculada_km - b.distancia_calculada_km;
    });
}

// Función de agrupación para comparativa. Agrupa productos que se repiten de distintos productores.
function obtenerProductosComparables(productos) {
    const grupos = {};
    for (let i = 0; i < productos.length; i++) {
        let nombreBase = obtenerNombreBase(productos[i].nombre);
        if (!grupos[nombreBase]) {
            grupos[nombreBase] = [];
        }
        grupos[nombreBase].push(productos[i]);
    }
    const grupoComparable = [];
    for (let nombre in grupos) {
        if (grupos[nombre].length > 1) {
            grupoComparable.push({
                nombreBase: nombre,
                productos: grupos[nombre]
            });
        }
    }
    return grupoComparable;
}

// Determina el color de la grafica para misma provincia (menor kilometraje)
function esMismaProvincia(zona, codigoPostal) {
    const provinciaConsumidor = obtenerCapitalPorCP(codigoPostal);
    const provinciaProductor = obtenerProvinciaPorZona(zona);

    if (!provinciaConsumidor || !provinciaProductor) {
        return false;
    }

    return provinciaConsumidor.cp === provinciaProductor.cp;
}