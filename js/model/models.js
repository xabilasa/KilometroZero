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