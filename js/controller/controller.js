'use strict'

async function iniciarAplicacion(){
    try{
        const productos = await consultarProductos();
        mostrarProductos(productos);
    } catch (error){
        console.error('Error al iniciar la aplicación:', error);
    }
}
