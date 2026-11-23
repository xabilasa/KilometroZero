<?php
// Cabeceras obligatorias para permitir peticiones AJAX (CORS) y formato JSON
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

try {
    // Configura tus credenciales reales de MySQL de tu hosting
    $host = 'db5021933190.hosting-data.io';
    $db   = 'dbs16352330'; 
    $user = 'dbu2980973';
    $pass = 'K1l0m3tr0Z3r0$$';
    
    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    
    // Recogemos el código postal enviado desde la URL (ej: api.php?cp=48001)
    $cp = isset($_GET['cp']) ? trim($_GET['cp']) : '';

    // Punto de referencia por defecto (Madrid centro) por si el CP está vacío o no es válido
    $latUsuario = 40.41680000;
    $lonUsuario = -3.70380000;

    if (!empty($cp) && strlen($cp) === 5) {
        $prefijoProvincia = substr($cp, 0, 2);
        
        // Mapeo escalable completo de las 52 provincias / capitales de España (incluyendo islas y ciudades autónomas)
        $coordenadasProvincias = [
            '01' => [42.8467, -2.6716], // Álava (Vitoria-Gasteiz)
            '02' => [38.9943, -1.8584], // Albacete
            '03' => [38.3452, -0.4810], // Alicante
            '04' => [36.8340, -2.4637], // Almería
            '05' => [40.6566, -4.6818], // Ávila
            '06' => [38.8794, -6.9706], // Badajoz
            '07' => [39.5696, 2.6502],  // Illes Balears (Palma)
            '08' => [41.3851, 2.1734],  // Barcelona
            '09' => [42.3439, -3.6969], // Burgos
            '10' => [39.4753, -6.3722], // Cáceres
            '11' => [36.5298, -6.2925], // Cádiz
            '12' => [39.9864, -0.0513], // Castellón de la Plana
            '13' => [38.9863, -3.9291], // Ciudad Real
            '14' => [37.8882, -4.7794], // Córdoba
            '15' => [43.3623, -8.4115], // A Coruña
            '16' => [40.0704, -2.1374], // Cuenca
            '17' => [41.9794, 2.8214],  // Girona
            '18' => [37.1773, -3.5986], // Granada
            '19' => [40.6286, -3.1619], // Guadalajara
            '20' => [43.3183, -1.9812], // Guipúzcoa (Donostia-San Sebastián)
            '21' => [37.2664, -6.9400], // Huelva
            '22' => [42.1401, -0.4089], // Huesca
            '23' => [37.7796, -3.7849], // Jaén
            '24' => [42.5987, -5.5671], // León
            '25' => [41.6176, 0.6229],  // Lleida
            '26' => [42.4650, -2.4456], // La Rioja (Logroño)
            '27' => [43.0097, -7.5567], // Lugo
            '28' => [40.4168, -3.7038], // Madrid
            '29' => [36.7213, -4.4214], // Málaga
            '30' => [37.9922, -1.1307], // Murcia
            '31' => [42.8125, -1.6458], // Navarra (Pamplona)
            '32' => [42.3400, -7.8639], // Ourense
            '33' => [43.3619, -5.8494], // Asturias (Oviedo)
            '34' => [42.0096, -4.5288], // Palencia
            '35' => [28.1235, -15.4363], // Las Palmas (Las Palmas de Gran Canaria)
            '36' => [42.4310, -8.6444], // Pontevedra
            '37' => [40.9701, -5.6635], // Salamanca
            '38' => [28.4698, -16.2548], // Santa Cruz de Tenerife
            '39' => [43.4623, -3.8099], // Cantabria (Santander)
            '40' => [40.9429, -4.1225], // Segovia
            '41' => [37.3891, -5.9845], // Sevilla
            '42' => [41.7640, -2.4682], // Soria
            '43' => [41.1189, 1.2445],  // Tarragona
            '44' => [40.3456, -1.1065], // Teruel
            '45' => [39.8628, -4.0273], // Toledo
            '46' => [39.4699, -0.3763], // Valencia
            '47' => [41.6523, -4.7286], // Valladolid
            '48' => [43.2630, -2.9350], // Bizkaia (Bilbao)
            '49' => [41.5034, -5.7460], // Zamora
            '50' => [41.6488, -0.8891], // Zaragoza
            '51' => [35.8894, -5.3213], // Ceuta
            '52' => [35.2923, -2.9383]  // Melilla
        ];

        if (array_key_exists($prefijoProvincia, $coordenadasProvincias)) {
            $latUsuario = $coordenadasProvincias[$prefijoProvincia][0];
            $lonUsuario = $coordenadasProvincias[$prefijoProvincia][1];
        }
    }

    // Consultamos todos los productos de la base de datos
    $stmt = $pdo->query("SELECT * FROM productos");
    $productos = $stmt->fetchAll();

    // Procesamos cada producto calculando la distancia real (aplicando factor de tortuosidad vial de 1.3)
    $radioTierraKm = 6371;
    $productosProcesados = [];

    foreach ($productos as $p) {
        $latProd = floatval($p['latitud']);
        $lonProd = floatval($p['longitud']);

        $dLat = deg2rad($latProd - $latUsuario);
        $dLon = deg2rad($lonProd - $lonUsuario);

        $a = sin($dLat / 2) * sin($dLat / 2) +
             cos(deg2rad($latUsuario)) * cos(deg2rad($latProd)) *
             sin($dLon / 2) * sin($dLon / 2);
        
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        $distanciaLineaRecta = $radioTierraKm * $c;

        // Aplicamos el factor de corrección de rutas terrestres
        $distanciaRealKm = round($distanciaLineaRecta * 1.3, 1);

        // Añadimos el cálculo dinámico al objeto producto
        $p['distancia_calculada_km'] = $distanciaRealKm;
        
        $productosProcesados[] = $p;
    }

    // Devolvemos el array completo en formato JSON estructurado
    echo json_encode($productosProcesados, JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    echo json_encode(['error' => 'Error en la API: ' . $e->getMessage()], JSON_UNESCAPED_UNICODE);
}
?>