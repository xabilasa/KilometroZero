<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

// Ajusta estas rutas según dónde esté iconos.php respecto a la raíz de la app
// Ejemplo: si iconos.php está en /api/iconos.php y las imágenes en /images/icons/
$iconsDir = realpath(__DIR__ . '/..') ? (__DIR__ . '/../images/icons') : (__DIR__ . '/images/icons');
$iconsWebPath = 'images/icons'; // Ruta relativa desde index.html hacia la carpeta de iconos

function normalizarPrimeraPalabra(string $texto): string {
    $texto = trim($texto);
    if ($texto === '') {
        return 'default';
    }
    $partes = preg_split('/\s+/u', $texto);
    $primera = mb_strtolower($partes[0], 'UTF-8');

    $reemplazos = [
        'á' => 'a', 'é' => 'e', 'í' => 'i', 'ó' => 'o', 'ú' => 'u',
        'ü' => 'u', 'ñ' => 'n'
    ];
    $limpia = strtr($primera, $reemplazos);
    $limpia = preg_replace('/[^a-z0-9_-]/', '', $limpia);

    return $limpia !== '' ? $limpia : 'default';
}

function crearIconoDefaultSiNoExiste(string $defaultPath): void {
    if (is_file($defaultPath)) {
        return;
    }
    $svgDefault = <<<SVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 36 36" width="36" height="36">
  <rect width="36" height="36" rx="8" fill="#e7f0e9"/>
  <circle cx="18" cy="18" r="8" fill="none" stroke="#2d5a3c" stroke-width="2.2"/>
  <path d="M18 10v16M12 16h12" stroke="#2d5a3c" stroke-width="2" stroke-linecap="round"/>
</svg>
SVG;
    @file_put_contents($defaultPath, $svgDefault);
}

function descargarIconoRepositorio(string $clave, array $diccionario): ?string {
    $termino = $diccionario[$clave] ?? $clave;
    $searchUrl = 'https://api.iconify.design/search?query=' . urlencode($termino) . '&prefixes=fluent-emoji-flat,noto&limit=1';

    $ctx = stream_context_create([
        'http' => [
            'timeout' => 4,
            'header'  => "User-Agent: KilometroCero-Sync/1.0\r\n"
        ]
    ]);

    $jsonSearch = @file_get_contents($searchUrl, false, $ctx);
    if ($jsonSearch === false) {
        return null;
    }

    $data = json_decode($jsonSearch, true);
    if (empty($data['icons'][0])) {
        return null;
    }

    [$prefix, $name] = explode(':', $data['icons'][0], 2);
    $svgUrl = "https://api.iconify.design/{$prefix}/{$name}.svg";
    $svg = @file_get_contents($svgUrl, false, $ctx);

    if ($svg !== false && str_contains($svg, '<svg')) {
        return $svg;
    }

    return null;
}

try {
    // Conexión con la BBDD para comprobar los productos y ver si hay nuevos
    $host = 'db5021933190.hosting-data.io';
    $db   = 'dbs16352330'; 
    $user = 'dbu2980973';
    $pass = 'K1l0m3tr0Z3r0$$';

    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    if (!is_dir($iconsDir)) {
        @mkdir($iconsDir, 0775, true);
    }

    $defaultFile = $iconsDir . '/default.svg';
    crearIconoDefaultSiNoExiste($defaultFile);

    // Diccionario de apoyo para mejorar búsquedas en repositorio
    $diccionario = [
        'manzana' => 'apple', 'peras' => 'pear', 'pera' => 'pear',
        'naranja' => 'orange', 'mandarina' => 'tangerine', 'limon' => 'lemon',
        'fresa' => 'strawberry', 'freson' => 'strawberry', 'cereza' => 'cherries',
        'kiwi' => 'kiwi-fruit', 'mango' => 'mango', 'platano' => 'banana',
        'melon' => 'melon', 'sandia' => 'watermelon', 'tomate' => 'tomato',
        'pimiento' => 'bell-pepper', 'guindilla' => 'hot-pepper', 'patata' => 'potato',
        'cebolla' => 'onion', 'ajo' => 'garlic', 'zanahoria' => 'carrot',
        'brocoli' => 'broccoli', 'berenjena' => 'eggplant', 'calabacin' => 'cucumber',
        'lechuga' => 'leafy-green', 'queso' => 'cheese-wedge', 'huevo' => 'egg',
        'huevos' => 'egg', 'pan' => 'bread', 'miel' => 'honey-pot',
        'aceite' => 'olive', 'arroz' => 'cooked-rice', 'pescado' => 'fish',
        'merluza' => 'fish', 'anchoa' => 'fish', 'sardina' => 'fish',
        'rape' => 'fish', 'mejillon' => 'clam', 'berberecho' => 'clam',
        'carne' => 'meat-on-bone', 'cordero' => 'meat-on-bone', 'pollo' => 'poultry-leg',
        'jamon' => 'ham', 'sidra' => 'beer-mug', 'vino' => 'wine-glass',
        'txakoli' => 'white-wine-glass', 'gildas' => 'olive', 'conserva'=> 'preserve',
        'alubia' => 'bean', 'alubias' => 'beans', 'nuez'=> 'nut', 'faba' => 'bean',
        'judión' => 'bean', 'garbanzo'=> 'chickpea', 'lenteja'=> 'lentil', 'avellana' => 'hazelnut',
        'torta'=> 'cake', 'piñón'=> 'pinion', 'yogur' => 'yogurt', 'arándanos' => 'blueberries', 
        'higos' => 'figs', 'ciruela'=> 'plum', 'frambuesa'=> 'raspberry', 'castanha' => 'chestnut',
        'kaki'=> 'kaki', 'granada' => 'grenade'

    ];

    $stmt = $pdo->query("SELECT DISTINCT nombre FROM productos WHERE nombre IS NOT NULL AND nombre <> ''");
    $filas = $stmt->fetchAll();

    $clavesUnicas = [];
    foreach ($filas as $fila) {
        $clave = normalizarPrimeraPalabra($fila['nombre']);
        $clavesUnicas[$clave] = true;
    }

    $mapaIconos = [];
    $nuevosDescargados = 0;
    $usandoDefault = 0;

    foreach (array_keys($clavesUnicas) as $clave) {
        $archivoDestino = $iconsDir . '/' . $clave . '.svg';

        if (is_file($archivoDestino)) {
            $mapaIconos[$clave] = $iconsWebPath . '/' . $clave . '.svg';
            continue;
        }

        // No existe en /images/icons/: intentamos traerlo del repositorio
        $svg = descargarIconoRepositorio($clave, $diccionario);

        if ($svg !== null && @file_put_contents($archivoDestino, $svg) !== false) {
            $mapaIconos[$clave] = $iconsWebPath . '/' . $clave . '.svg';
            $nuevosDescargados++;
        } else {
            // Si no existe o falla la descarga, copiamos/usamos el icono por defecto
            if (!is_file($archivoDestino) && is_file($defaultFile)) {
                @copy($defaultFile, $archivoDestino);
            }
            $mapaIconos[$clave] = is_file($archivoDestino)
                ? ($iconsWebPath . '/' . $clave . '.svg')
                : ($iconsWebPath . '/default.svg');
            $usandoDefault++;
        }
    }

    echo json_encode([
        'ok' => true,
        'total_claves' => count($mapaIconos),
        'nuevos_descargados' => $nuevosDescargados,
        'con_default' => $usandoDefault,
        'iconos' => $mapaIconos
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => 'Error al sincronizar iconos: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}