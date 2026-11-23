'use strict'

async function consultarProductos(){
    const apiURL = "../api/api.php";
    try{
        const respuesta = await fetch (apiURL);
        if (!respuesta.ok) {
            throw new Error('Error HTTP: ${respuesta.status}');
        }
        const datos = await respuesta.json();
        console.log(datos);
    } catch (error) {
        console.error ('Ha habido un problema con la petición:', error);
    }
}

// FUNCIÓN consultarProductos()

//     1. Definir la dirección de la API.

//     2. Realizar una petición FETCH a esa dirección.

//     3. Cuando llegue la respuesta:
//         a. Comprobar si la respuesta HTTP ha sido correcta.
//         b. Si no ha sido correcta, generar un error.
//         c. Si ha sido correcta, convertir el contenido JSON
//            en un objeto JavaScript.

//     4. Cuando termine la conversión:
//         a. Comprobar que los datos recibidos tienen el formato esperado.
//         b. Devolver los productos.

//     5. Si ocurre algún error durante la petición o el procesamiento:
//         a. Capturar el error.
//         b. Informar del error.
//         c. Propagarlo para que el controlador pueda gestionarlo.