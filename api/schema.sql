CREATE DATABASE IF NOT EXISTS kilometrocero
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE kilometrocero;

CREATE TABLE IF NOT EXISTS productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    productor VARCHAR(150) NOT NULL,
    zona VARCHAR(100) NOT NULL,
    latitud DECIMAL(10,8) NOT NULL,    -- Coordenadas del productor
    longitud DECIMAL(11,8) NOT NULL,   -- Coordenadas del productor
    co2_base_ahorro DECIMAL(5,2) NOT NULL, -- Factor base de ahorro ecológico del producto (frente a importación industrial)
    coste_envio_kg DECIMAL(5,2) NOT NULL   -- Coste estimado de transporte/envío por kg
);

-- Add the coordinates when upgrading a database created with the earlier schema.
SET @add_latitud = IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'productos' AND COLUMN_NAME = 'latitud') = 0,
  'ALTER TABLE productos ADD COLUMN latitud DECIMAL(10,8) NOT NULL DEFAULT 40.41680000',
  'SELECT 1'
);
PREPARE add_latitud_stmt FROM @add_latitud;
EXECUTE add_latitud_stmt;
DEALLOCATE PREPARE add_latitud_stmt;

SET @add_longitud = IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'productos' AND COLUMN_NAME = 'longitud') = 0,
  'ALTER TABLE productos ADD COLUMN longitud DECIMAL(11,8) NOT NULL DEFAULT -3.70380000',
  'SELECT 1'
);
PREPARE add_longitud_stmt FROM @add_longitud;
EXECUTE add_longitud_stmt;
DEALLOCATE PREPARE add_longitud_stmt;

-- Vaciado previo opcional si se ejecuta varias veces
TRUNCATE TABLE productos;

-- Inserción masiva de todo el catálogo adaptado al nuevo esquema (co2_base_ahorro, coste_envio_kg)
INSERT INTO productos (nombre, categoria, productor, zona, latitud, longitud, co2_base_ahorro, coste_envio_kg) VALUES
-- ==========================================
-- REGISTROS BASE Y SELECCIÓN INICIAL
-- ==========================================
('Manzana reineta', 'Frutas', 'Productores de Girona', 'Girona, Cataluña', 41.97940000, 2.82140000, 0.42, 1.80),
('Tomate rosa', 'Verduras', 'Huerta de Almería', 'Almería, Andalucía', 36.83400000, -2.46370000, 0.35, 2.10),
('Aceite de oliva virgen extra', 'Despensa', 'Cooperativa olivarera de Jaén', 'Jaén, Andalucía', 37.77960000, -3.78490000, 0.68, 2.50),
('Queso de oveja', 'Lácteos', 'Quesería de Ávila', 'Ávila, Castilla y León', 40.65660000, -4.68180000, 0.68, 2.30),
('Lenteja pardina', 'Despensa', 'Productores de Palencia', 'Palencia, Castilla y León', 42.00960000, -4.52880000, 0.24, 1.90),
('Naranja valenciana', 'Frutas', 'Cooperativa de la Ribera', 'Valencia, Comunidad Valenciana', 39.46990000, -0.37630000, 0.31, 2.00),

-- ==========================================
-- PAÍS VASCO: VERDURAS Y HUERTA (Caseríos y Cooperativas)
-- ==========================================
('Pimiento de Gernika Eusko Label', 'Verduras', 'Barazkiak Urdaibai', 'Gernika, Bizkaia', 43.31470000, -2.67750000, 0.90, 1.50),
('Alubia Roja de Tolosa', 'Despensa', 'Asociación de Productores de Alubia de Tolosa', 'Tolosa, Gipuzkoa', 43.13480000, -2.07800000, 0.75, 2.20),
('Guindilla de Ibarra Eusko Label', 'Verduras', 'Ibarrako Piparrak Kooperatiba', 'Ibarra, Gipuzkoa', 43.13190000, -2.06170000, 0.65, 2.50),
('Tomate Feo de Tudela y Huerta Alavesa', 'Verduras', 'Huerta Ecológica Rioja Alavesa', 'Laguardia, Álava', 42.55420000, -2.58440000, 1.15, 1.90),
('Puerro Fresco de Baserri', 'Verduras', 'Baserri Ekoizleak Mungia', 'Mungia, Bizkaia', 43.35470000, -2.84720000, 0.55, 1.40),
('Acelga Verde Ecológica de Bakio', 'Verduras', 'Lur Lan Bakio', 'Bakio, Bizkaia', 43.42720000, -2.81140000, 0.50, 1.40),
('Calabacín de Huerta Guipuzcoana', 'Verduras', 'Baratze Ekologikoa Azpeitia', 'Azpeitia, Gipuzkoa', 43.18220000, -2.26500000, 0.60, 1.60),
('Patata de Álava Eusko Label', 'Verduras', 'Udapa Sociedad Cooperativa', 'Vitoria-Gasteiz, Álava', 42.84670000, -2.67160000, 0.80, 1.30),
('Lechuga Batavia de Caserío', 'Verduras', 'Ekoizpenak Derio', 'Derio, Bizkaia', 43.29170000, -2.88580000, 0.40, 1.20),
('Cebolla Morada de Zalla', 'Verduras', 'Zallako Tipula Gorria', 'Zalla, Bizkaia', 43.21360000, -3.13360000, 0.70, 1.50),
('Berenjena Negra de Huerta', 'Verduras', 'Nekazaritza Ekologikoa Zarautz', 'Zarautz, Gipuzkoa', 43.28440000, -2.16920000, 0.75, 1.70),
('Vaina Verde Fina de Euskadi', 'Verduras', 'Baserritarrak Goierri', 'Ordizia, Gipuzkoa', 43.05420000, -2.17830000, 0.85, 1.80),
('Remolacha Roja Ecológica', 'Verduras', 'Ortu Ekologikoa Amurrio', 'Amurrio, Álava', 43.05220000, -3.00110000, 0.60, 1.50),
('Espinaca Fresca de Temporada', 'Verduras', 'Hortalizas Valle de Ayala', 'Llodio, Álava', 43.14360000, -2.96220000, 0.45, 1.40),
('Zanahoria Manojo Ecológica', 'Verduras', 'Finca Bio Oiartzun', 'Oiartzun, Gipuzkoa', 43.30000000, -1.86060000, 0.65, 1.90),

-- ==========================================
-- PAÍS VASCO: FRUTAS (Caseríos y Sidrerías)
-- ==========================================
('Manzana Errezil (Reineta Vasca)', 'Frutas', 'Sagardogileak Astigarraga', 'Astigarraga, Gipuzkoa', 43.28140000, -1.94670000, 1.30, 1.80),
('Kiwi Verde del Cantábrico', 'Frutas', 'Kiwiak Getaria', 'Getaria, Gipuzkoa', 43.30440000, -2.20360000, 2.80, 2.10),
('Higos Frescos de Baserri', 'Frutas', 'Frutagintza Markina', 'Markina-Xemein, Bizkaia', 43.26810000, -2.49690000, 1.10, 1.95),
('Ciruela Claudia de Álava', 'Frutas', 'Frutas Montaña Alavesa', 'Campezo, Álava', 42.67140000, -2.35190000, 1.20, 2.00),
('Arándanos Ecológicos de Bizkaia', 'Frutas', 'Baia Ekologikoak Karrantza', 'Karrantza, Bizkaia', 43.22560000, -3.35690000, 1.90, 2.50),
('Frambuesa Fresca de Gipuzkoa', 'Frutas', 'Fruitu Gorriak Hernani', 'Hernani, Gipuzkoa', 43.26640000, -1.97610000, 1.85, 2.60),
('Cereza de Primavera del Valle', 'Frutas', 'Cerezas Valdegovía', 'Valdegovía, Álava', 42.84890000, -3.09940000, 1.40, 2.20),
('Pera de Agua de Huerta Vasca', 'Frutas', 'Caserío Frutal Elorrio', 'Elorrio, Bizkaia', 43.13060000, -2.54250000, 0.95, 1.70),

-- ==========================================
-- PAÍS VASCO: PESCADOS (Cofradías del Cantábrico)
-- ==========================================
('Anchoa del Cantábrico Fresca', 'Pescados', 'Cofradía de Pescadores de Ondarroa', 'Ondarroa, Bizkaia', 43.32190000, -2.41940000, 1.20, 2.40),
('Verdel (Caballa) de Bajura', 'Pescados', 'Cofradía de Pescadores de Getaria', 'Getaria, Gipuzkoa', 43.30440000, -2.20360000, 0.95, 2.20),
('Merluza de Pincho del Cantábrico', 'Pescados', 'Cofradía San Pedro Pasaia', 'Pasaia, Gipuzkoa', 43.32470000, -1.92030000, 1.60, 2.90),
('Txitxarro (Jurel) Fresco de Costa', 'Pescados', 'Cofradía de Lekeitio', 'Lekeitio, Bizkaia', 43.36390000, -2.50360000, 0.90, 2.10),
('Sardina del Cantábrico', 'Pescados', 'Cofradía de Santurtzi', 'Santurtzi, Bizkaia', 43.32860000, -3.03190000, 0.85, 1.80),
('Besugo de Invierno de Bajura', 'Pescados', 'Cofradía de Hondarribia', 'Hondarribia, Gipuzkoa', 43.36250000, -1.79170000, 1.75, 3.20),
('Rape Blanco del Cantábrico', 'Pescados', 'Pescadores Artesanales Mutriku', 'Mutriku, Gipuzkoa', 43.30690000, -2.38500000, 1.50, 2.80),

-- ==========================================
-- PAÍS VASCO: CARNES Y DESPENSA ARTESANA
-- ==========================================
('Cordero Lechal Eusko Label', 'Carnes', 'Ganaderos Latxa Karrantza', 'Karrantza, Bizkaia', 43.22560000, -3.35690000, 2.80, 3.10),
('Pollo de Caserío Eusko Label', 'Carnes', 'LumaGorri Kooperatiba', 'Zerain, Gipuzkoa', 43.01220000, -2.27360000, 1.90, 2.50),
('Carne de Potro de Montaña Alavesa', 'Carnes', 'Ganadería Gorbeia', 'Zuia, Álava', 42.95690000, -2.82080000, 2.50, 2.80),
('Costilla de Cerdo Euskal Txerria', 'Carnes', 'Euskal Txerri Hazleak', 'Lekunberri, Gipuzkoa/Navarra', 43.00310000, -1.89390000, 2.30, 2.70),
('Miel Cruda de Brezo y Eucalipto', 'Despensa', 'Erlezainak Enkarterri', 'Gordexola, Bizkaia', 43.18060000, -3.07310000, 0.60, 1.60),
('Sidra Natural Euskal Sagardoa', 'Despensa', 'Sidrería Zapiain', 'Astigarraga, Gipuzkoa', 43.28140000, -1.94670000, 0.85, 2.10),
('Txakoli de Getaria D.O.', 'Despensa', 'Bodega Txomin Etxaniz', 'Getaria, Gipuzkoa', 43.30440000, -2.20360000, 0.95, 2.20),
('Txakoli de Bizkaia D.O.', 'Despensa', 'Bodega Itsasmendi', 'Gernika, Bizkaia', 43.31470000, -2.67750000, 0.80, 1.90),
('Queso Azul de Oveja Latxa', 'Despensa', 'Quesería Aldanondo', 'Agurain, Álava', 42.84920000, -2.38940000, 1.30, 2.40),
('Sal de Manantial de Añana', 'Despensa', 'Fundación Valle Salado de Añana', 'Salinas de Añana, Álava', 42.80170000, -2.98690000, 0.70, 1.80),
('Conserva de Bonito en Aceite', 'Despensa', 'Conservas Ortiz', 'Ondarroa, Bizkaia', 43.32190000, -2.41940000, 0.90, 2.20),
('Gildas Artesanas del Cantábrico', 'Despensa', 'Conservas Serrats', 'Bermeo, Bizkaia', 43.42160000, -2.72140000, 0.75, 1.90),
('Huevos Camperos Eusko Label', 'Despensa', 'Euskal Oiloa Baserria', 'Dima, Bizkaia', 43.14440000, -2.75220000, 0.65, 1.70),
('Yogur Artesano de Caserío', 'Despensa', 'Esnekiak Goierri', 'Idiazabal, Gipuzkoa', 43.01250000, -2.23410000, 0.70, 1.90),
('Pan de Masa Madre y Trigo Antiguo', 'Despensa', 'Okindegi Ekologikoa Durango', 'Durango, Bizkaia', 43.16860000, -2.63220000, 0.50, 1.50),

-- ==========================================
-- NAVARRA Y LA RIOJA (Proximidad inmediata)
-- ==========================================
('Espárrago Blanco de Navarra IGP', 'Verduras', 'Conservas y Frescos de Lodosa', 'Lodosa, Navarra', 42.42420000, -2.07830000, 1.10, 2.30),
('Pimiento del Piquillo de Lodosa', 'Verduras', 'Huerta del Ebro Navarra', 'Lodosa, Navarra', 42.42420000, -2.07830000, 1.05, 2.30),
('Cogollos de Tudela Frescos', 'Verduras', 'Agricultores de la Mejana', 'Tudela, Navarra', 42.06170000, -1.60670000, 0.95, 2.50),
('Cardo Rojo de la Ribera', 'Verduras', 'Verduras Tradicionales Corella', 'Corella, Navarra', 42.11470000, -1.78670000, 0.90, 2.40),
('Borraja Fresca del Valle del Ebro', 'Verduras', 'Huerta Ecológica Cintruénigo', 'Cintruénigo, Navarra', 42.07890000, -1.80530000, 0.85, 2.40),
('Queso Roncal D.O.P.', 'Despensa', 'Quesería Larra', 'Burgui, Navarra', 42.72190000, -1.00060000, 1.40, 2.70),
('Chistorra Artesana de Navarra', 'Carnes', 'Embutidos Arrieta', 'Zubiri, Navarra', 42.93060000, -1.50470000, 1.25, 2.20),
('Coliflor de Calahorra IGP', 'Verduras', 'Cooperativa Hortícola Calahorra', 'Calahorra, La Rioja', 42.30500000, -1.96530000, 0.95, 2.30),
('Ciruela Claudia de Nalda', 'Frutas', 'Frutales del Iregua', 'Nalda, La Rioja', 42.33390000, -2.48720000, 1.10, 2.10),
('Nuez de Pedroso D.O.P.', 'Despensa', 'Asociación Nuez de Pedroso', 'Pedroso, La Rioja', 42.30030000, -2.71890000, 0.80, 2.00),
('Aceite de Oliva Virgen Extra de La Rioja', 'Despensa', 'Almazara Ecológica Alfaro', 'Alfaro, La Rioja', 42.17830000, -1.74860000, 1.50, 2.50),

-- ==========================================
-- ASTURIAS Y GALICIA (Cornisa Cantábrica)
-- ==========================================
('Faba Asturiana IGP', 'Despensa', 'Productores de Faba de Pravia', 'Pravia, Asturias', 43.48920000, -6.11280000, 1.15, 2.90),
('Manzana de Sidra Asturiana', 'Frutas', 'Pomaradas de Villaviciosa', 'Villaviciosa, Asturias', 43.48140000, -5.43560000, 1.40, 2.70),
('Queso Gamoneu del Puerto', 'Despensa', 'Quesería Demués', 'Onís, Asturias', 43.33580000, -4.96670000, 1.55, 2.60),
('Pixín (Rape) Negro del Cantábrico', 'Pescados', 'Rula de Avilés', 'Avilés, Asturias', 43.55470000, -5.92480000, 1.80, 3.10),
('Pimiento de Herbón (Padrón)', 'Verduras', 'Sociedad Agraria de Herbón', 'Padrón, A Coruña', 42.73810000, -8.66060000, 2.10, 3.50),
('Grelos Frescos de Galicia IGP', 'Verduras', 'Horta Galega Lugo', 'Lugo, Galicia', 43.00970000, -7.55670000, 1.85, 3.30),
('Patata de Galicia IGP (Kennebec)', 'Verduras', 'Agricultores de A Limia', 'Xinzo de Limia, Ourense', 42.06360000, -7.72440000, 1.70, 3.20),
('Mejillón de Galicia D.O.P.', 'Pescados', 'Bateeiros de Arousa', 'Vilagarcía de Arousa, Pontevedra', 42.59640000, -8.76440000, 2.20, 3.50),
('Berberecho de la Ría de Noia', 'Pescados', 'Cofradía de Pescadores de Noia', 'Noia, A Coruña', 42.78500000, -8.88780000, 2.30, 3.60),
('Ternera Gallega Suprema IGP', 'Carnes', 'Ganadería Sostenible Os Ancares', 'Becerreá, Lugo', 42.85360000, -7.16190000, 3.10, 3.40),
('Castanha de Galicia IGP', 'Frutas', 'Soutos do Courel', 'Folgoso do Courel, Lugo', 42.58890000, -7.19560000, 1.45, 3.10),

-- ==========================================
-- ARAGÓN Y CASTILLA Y LEÓN (Interior Norte)
-- ==========================================
('Cebolla Fuentes de Ebro D.O.P.', 'Verduras', 'Hortícolas Fuentes de Ebro', 'Fuentes de Ebro, Zaragoza', 41.51220000, -0.62920000, 1.25, 2.60),
('Tomate Rosa de Barbastro', 'Verduras', 'Asociación Hortelanos del Alto Aragón', 'Barbastro, Huesca', 42.03670000, 0.12690000, 1.40, 2.80),
('Cereza de Bolea', 'Frutas', 'Cooperativa Agrícola de Bolea', 'Bolea, Huesca', 42.25890000, -0.55360000, 1.30, 2.50),
('Borraja de Zaragoza', 'Verduras', 'Huerta del Gállego', 'Zuera, Zaragoza', 41.86890000, -0.78830000, 1.15, 2.60),
('Jamón de Teruel D.O.P.', 'Despensa', 'Secadero Artesanal Mora de Rubielos', 'Mora de Rubielos, Teruel', 40.25310000, -0.75250000, 2.10, 3.10),
('Manzana Reineta del Bierzo D.O.P.', 'Frutas', 'Fruticultores del Bierzo', 'Carracedelo, León', 42.55440000, -6.73220000, 1.75, 3.00),
('Pimiento Asado del Bierzo IGP', 'Verduras', 'Huerta Tradicional Camponaraya', 'Camponaraya, León', 42.58110000, -6.67030000, 1.60, 2.95),
('Cereza del Valle de las Caderechas', 'Frutas', 'Productores de las Caderechas', 'Salas de Bureba, Burgos', 42.70190000, -3.47330000, 0.90, 1.80),
('Lechuga de Medina de Pomar', 'Verduras', 'Huerta de las Merindades', 'Medina de Pomar, Burgos', 42.92780000, -3.48690000, 0.70, 1.60),
('Morcilla de Burgos IGP', 'Carnes', 'Embutidos Cardeña', 'Cardeñajimeno, Burgos', 42.33080000, -3.62170000, 1.30, 2.10),
('Lechazo de Castilla y León IGP', 'Carnes', 'Ganaderos Tierra de Campos', 'Medina de Rioseco, Valladolid', 41.88310000, -5.04280000, 2.70, 2.80),
('Garbanzo de Fuentesaúco IGP', 'Despensa', 'Legumbres de la Guareña', 'Fuentesaúco, Zamora', 41.23110000, -5.49720000, 1.10, 2.70),
('Lenteja de la Armuña IGP', 'Despensa', 'Cooperativa Campo Charro', 'Gomecello, Salamanca', 41.04310000, -5.53440000, 1.15, 2.80),
('Carne de Ávila IGP', 'Carnes', 'Ganadería Avileña Negra Ibérica', 'Piedrahíta, Ávila', 40.46360000, -5.32720000, 3.20, 3.20),
('Judión de la Granja IGP', 'Despensa', 'Horticultores del Real Sitio', 'San Ildefonso, Segovia', 40.90140000, -4.00690000, 1.20, 2.70),
('Piñón Blanco de Castilla', 'Despensa', 'Piñoneros de Pedrajas', 'Pedrajas de San Esteban, Valladolid', 41.34190000, -4.58080000, 0.95, 2.50),

-- ==========================================
-- RESTO DE ESPAÑA (Productos Estacionales y Exclusivos)
-- ==========================================
('Naranja Navelina de Valencia IGP', 'Frutas', 'Cítricos La Ribera', 'Alzira, Valencia', 39.15140000, -0.43500000, 2.40, 3.20),
('Mandarina Clementina de Castellón', 'Frutas', 'Huerta de la Plana', 'Burriana, Castellón', 39.88940000, -0.08390000, 2.20, 3.10),
('Alcachofa de Benicarló D.O.P.', 'Verduras', 'Agricultores del Maestrazgo', 'Benicarló, Castellón', 40.41670000, 0.42720000, 1.95, 2.90),
('Kaki Persimon Ribera del Xúquer', 'Frutas', 'Cooperativa Agrícola Carlet', 'Carlet, Valencia', 39.22640000, -0.52140000, 2.35, 3.10),
('Granada Mollar de Elche D.O.P.', 'Frutas', 'Productores del Camp d Elx', 'Elche, Alicante', 38.26690000, -0.69830000, 2.60, 3.45),
('Níspero de Callosa d En Sarrià', 'Frutas', 'Cooperativa Ruchey', 'Callosa d En Sarrià, Alicante', 38.65140000, -0.12220000, 2.50, 3.30),
('Melón de Torre Pacheco', 'Frutas', 'Melones del Campo de Cartagena', 'Torre Pacheco, Murcia', 37.74280000, -0.95390000, 2.70, 3.50),
('Limón Fino de Murcia', 'Frutas', 'Cítricos del Valle del Guadalentín', 'Librilla, Murcia', 37.88690000, -1.35140000, 2.45, 3.40),
('Brócoli Fresco del Valle del Segura', 'Verduras', 'Hortícola Lorca Bio', 'Lorca, Murcia', 37.67110000, -1.70170000, 2.10, 3.40),
('Mango Osteen de la Axarquía', 'Frutas', 'Frutas Tropicales Vélez', 'Vélez-Málaga, Málaga', 36.78250000, -4.10140000, 3.80, 3.90),
('Chirimoya de la Costa Tropical', 'Frutas', 'Cultivos Subtropicales Almuñécar', 'Almuñécar, Granada', 36.73390000, -3.69080000, 3.90, 3.95),
('Fresa y Fresón de Palos', 'Frutas', 'Fresas de Doñana Bio', 'Palos de la Frontera, Huelva', 37.22890000, -6.89310000, 3.40, 3.80),
('Aceite de Oliva Virgen Extra Hojiblanca', 'Despensa', 'Almazara Subbética Cordobesa', 'Priego de Córdoba, Córdoba', 37.43830000, -4.19640000, 3.10, 3.60),
('Ajo Morado de Las Pedroñeras IGP', 'Verduras', 'Cooperativa San Isidro', 'Las Pedroñeras, Cuenca', 39.44860000, -2.67190000, 1.50, 2.80),
('Berenjena de Almagro IGP', 'Despensa', 'Conservas Campo de Calatrava', 'Almagro, Ciudad Real', 38.88890000, -3.71190000, 1.65, 2.90),
('Azafrán de La Mancha D.O.P.', 'Despensa', 'Productores de Azafrán Consuegra', 'Consuegra, Toledo', 39.46190000, -3.60690000, 0.90, 2.20),
('Calçots de Valls IGP', 'Verduras', 'Agricultores de l Alt Camp', 'Valls, Tarragona', 41.28580000, 1.24860000, 1.75, 2.80),
('Avellana de Reus D.O.P.', 'Despensa', 'Unió Agrària Cooperativa', 'Reus, Tarragona', 41.15580000, 1.10690000, 1.40, 2.75),
('Arroz Bomba del Delta del Ebro', 'Despensa', 'Cámara Arrocera del Montsià', 'Amposta, Tarragona', 40.71060000, 0.57920000, 1.60, 2.90),
('Cereza del Jerte D.O.P.', 'Frutas', 'Agrupación de Cooperativas Valle del Jerte', 'Valdastillas, Cáceres', 40.13280000, -5.87890000, 2.25, 3.10),
('Torta del Casar D.O.P.', 'Despensa', 'Quesería Artesana del Casar', 'Casar de Cáceres, Cáceres', 39.56140000, -6.41670000, 1.90, 3.20),
('Plátano de Canarias IGP (Producción Ecológica)', 'Frutas', 'Plataneros Sostenibles La Palma', 'Los Llanos de Aridane, Santa Cruz de Tenerife', 28.65860000, -17.91810000, 4.50, 5.50);