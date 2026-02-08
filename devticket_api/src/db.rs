use rusqlite::Connection;
use anyhow::Result;

pub fn initialize(conn: &Connection) -> Result<()> {
    conn.execute_batch(
        "
        CREATE TABLE IF NOT EXISTS stations (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            city TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            station_type TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS destinations (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            city TEXT NOT NULL,
            state TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            description TEXT NOT NULL,
            region TEXT NOT NULL DEFAULT 'Central',
            highlights TEXT NOT NULL DEFAULT '[]',
            trip_type TEXT NOT NULL DEFAULT 'day_trip'
        );

        CREATE TABLE IF NOT EXISTS connections (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            from_station_id TEXT NOT NULL,
            to_destination_id TEXT NOT NULL,
            travel_time_minutes INTEGER NOT NULL,
            number_of_transfers INTEGER NOT NULL,
            transport_types TEXT NOT NULL,
            ice_minutes INTEGER,
            ice_price_euros REAL,
            FOREIGN KEY (from_station_id) REFERENCES stations(id),
            FOREIGN KEY (to_destination_id) REFERENCES destinations(id)
        );

        CREATE TABLE IF NOT EXISTS route_segments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            from_station_id TEXT NOT NULL,
            to_destination_id TEXT NOT NULL,
            sequence_order INTEGER NOT NULL,
            from_stop TEXT NOT NULL,
            to_stop TEXT NOT NULL,
            transport_type TEXT NOT NULL,
            line TEXT NOT NULL,
            duration_minutes INTEGER NOT NULL
        );
        "
    )?;

    let count: i64 = conn.query_row("SELECT COUNT(*) FROM stations", [], |row| row.get(0))?;
    if count == 0 {
        seed_data(conn)?;
    }

    Ok(())
}

fn seed_data(conn: &Connection) -> Result<()> {
    // ── Stations (major Hauptbahnhöfe) ──
    let stations = vec![
        ("berlin_hbf", "Berlin Hauptbahnhof", "Berlin", 52.5251, 13.3694, "REGIONAL"),
        ("hamburg_hbf", "Hamburg Hauptbahnhof", "Hamburg", 53.5526, 10.0067, "REGIONAL"),
        ("munich_hbf", "München Hauptbahnhof", "Munich", 48.1402, 11.5581, "REGIONAL"),
        ("cologne_hbf", "Köln Hauptbahnhof", "Cologne", 50.9429, 6.9589, "REGIONAL"),
        ("frankfurt_hbf", "Frankfurt Hauptbahnhof", "Frankfurt", 50.1070, 8.6632, "REGIONAL"),
        ("stuttgart_hbf", "Stuttgart Hauptbahnhof", "Stuttgart", 48.7841, 9.1817, "REGIONAL"),
        ("dusseldorf_hbf", "Düsseldorf Hauptbahnhof", "Dusseldorf", 51.2201, 6.7925, "REGIONAL"),
        ("leipzig_hbf", "Leipzig Hauptbahnhof", "Leipzig", 51.3455, 12.3821, "REGIONAL"),
        ("dresden_hbf", "Dresden Hauptbahnhof", "Dresden", 51.0404, 13.7320, "REGIONAL"),
        ("nuremberg_hbf", "Nürnberg Hauptbahnhof", "Nuremberg", 49.4457, 11.0831, "REGIONAL"),
        ("hannover_hbf", "Hannover Hauptbahnhof", "Hannover", 52.3767, 9.7413, "REGIONAL"),
        ("bremen_hbf", "Bremen Hauptbahnhof", "Bremen", 53.0831, 8.8137, "REGIONAL"),
        ("heidelberg_hbf", "Heidelberg Hauptbahnhof", "Heidelberg", 49.4040, 8.6758, "REGIONAL"),
        ("freiburg_hbf", "Freiburg Hauptbahnhof", "Freiburg", 47.9975, 7.8426, "REGIONAL"),
        ("potsdam_hbf", "Potsdam Hauptbahnhof", "Potsdam", 52.3919, 13.0667, "REGIONAL"),
        ("mainz_hbf", "Mainz Hauptbahnhof", "Mainz", 50.0012, 8.2590, "REGIONAL"),
        ("erfurt_hbf", "Erfurt Hauptbahnhof", "Erfurt", 50.9722, 11.0388, "REGIONAL"),
        ("rostock_hbf", "Rostock Hauptbahnhof", "Rostock", 54.0787, 12.1313, "REGIONAL"),
        ("kiel_hbf", "Kiel Hauptbahnhof", "Kiel", 54.3144, 10.1315, "REGIONAL"),
        ("luebeck_hbf", "Lübeck Hauptbahnhof", "Lübeck", 53.8688, 10.6904, "REGIONAL"),
        ("augsburg_hbf", "Augsburg Hauptbahnhof", "Augsburg", 48.3652, 10.8859, "REGIONAL"),
        ("regensburg_hbf", "Regensburg Hauptbahnhof", "Regensburg", 49.0141, 12.0988, "REGIONAL"),
        ("wuerzburg_hbf", "Würzburg Hauptbahnhof", "Würzburg", 49.8012, 9.9362, "REGIONAL"),
        ("konstanz_bf", "Konstanz Bahnhof", "Konstanz", 47.6625, 9.1762, "REGIONAL"),
        ("trier_hbf", "Trier Hauptbahnhof", "Trier", 49.7568, 6.6414, "REGIONAL"),
        ("karlsruhe_hbf", "Karlsruhe Hauptbahnhof", "Karlsruhe", 48.9936, 8.4018, "REGIONAL"),
        ("mannheim_hbf", "Mannheim Hauptbahnhof", "Mannheim", 49.4796, 8.4690, "REGIONAL"),
        ("bonn_hbf", "Bonn Hauptbahnhof", "Bonn", 50.7323, 7.0972, "REGIONAL"),
        ("dortmund_hbf", "Dortmund Hauptbahnhof", "Dortmund", 51.5175, 7.4592, "REGIONAL"),
        ("essen_hbf", "Essen Hauptbahnhof", "Essen", 51.4508, 7.0131, "REGIONAL"),
        ("muenster_hbf", "Münster Hauptbahnhof", "Münster", 51.9566, 7.6354, "REGIONAL"),
        ("aachen_hbf", "Aachen Hauptbahnhof", "Aachen", 50.7678, 6.0907, "REGIONAL"),
        ("bamberg_bf", "Bamberg Bahnhof", "Bamberg", 49.9007, 10.8990, "REGIONAL"),
        ("ulm_hbf", "Ulm Hauptbahnhof", "Ulm", 48.3994, 9.9820, "REGIONAL"),
        ("goettingen_bf", "Göttingen Bahnhof", "Göttingen", 51.5364, 9.9264, "REGIONAL"),
        ("magdeburg_hbf", "Magdeburg Hauptbahnhof", "Magdeburg", 52.1303, 11.6270, "REGIONAL"),
        ("halle_hbf", "Halle Hauptbahnhof", "Halle", 51.4776, 11.9870, "REGIONAL"),
        ("chemnitz_hbf", "Chemnitz Hauptbahnhof", "Chemnitz", 50.8397, 12.9302, "REGIONAL"),
        ("schwerin_hbf", "Schwerin Hauptbahnhof", "Schwerin", 53.6352, 11.4084, "REGIONAL"),
        ("koblenz_hbf", "Koblenz Hauptbahnhof", "Koblenz", 50.3510, 7.5896, "REGIONAL"),
        ("saarbruecken_hbf", "Saarbrücken Hauptbahnhof", "Saarbrücken", 49.2414, 6.9910, "REGIONAL"),
        ("wiesbaden_hbf", "Wiesbaden Hauptbahnhof", "Wiesbaden", 50.0706, 8.2434, "REGIONAL"),
        ("bielefeld_hbf", "Bielefeld Hauptbahnhof", "Bielefeld", 52.0292, 8.5325, "REGIONAL"),
        ("braunschweig_hbf", "Braunschweig Hauptbahnhof", "Braunschweig", 52.2521, 10.5404, "REGIONAL"),
        ("kassel_wilhelmshoehe", "Kassel-Wilhelmshöhe", "Kassel", 51.3127, 9.4464, "REGIONAL"),
        ("oldenburg_hbf", "Oldenburg Hauptbahnhof", "Oldenburg", 53.1434, 8.2213, "REGIONAL"),
        ("osnabrueck_hbf", "Osnabrück Hauptbahnhof", "Osnabrück", 52.2727, 8.0619, "REGIONAL"),
        ("passau_hbf", "Passau Hauptbahnhof", "Passau", 48.5746, 13.4581, "REGIONAL"),
        ("stralsund_hbf", "Stralsund Hauptbahnhof", "Stralsund", 54.3060, 13.0912, "REGIONAL"),
        ("garmisch_bf", "Garmisch-Partenkirchen", "Garmisch-Partenkirchen", 47.4920, 11.0960, "REGIONAL"),
    ];

    for (id, name, city, lat, lng, stype) in &stations {
        conn.execute(
            "INSERT INTO stations (id, name, city, latitude, longitude, station_type) VALUES (?1, ?2, ?3, ?4, ?5, ?6)",
            rusqlite::params![id, name, city, lat, lng, stype],
        )?;
    }

    // ── Destinations with region, highlights, and trip_type ──
    // Format: (id, name, city, state, lat, lng, description, region, highlights_json, trip_type)
    let destinations: Vec<(&str, &str, &str, &str, f64, f64, &str, &str, &str, &str)> = vec![
        ("berlin", "Berlin", "Berlin", "Berlin", 52.5200, 13.4050,
         "Capital city - Brandenburg Gate, Museum Island, East Side Gallery, Reichstag",
         "East", r#"["Brandenburg Gate","Museum Island (UNESCO)","East Side Gallery","Reichstag Building","Checkpoint Charlie","KaDeWe Shopping","Alexanderplatz","Berlin TV Tower"]"#,
         "weekend"),
        ("hamburg", "Hamburg", "Hamburg", "Hamburg", 53.5511, 9.9937,
         "Port city - Speicherstadt, Elbphilharmonie, Reeperbahn, Miniatur Wunderland",
         "North", r#"["Speicherstadt (UNESCO)","Elbphilharmonie","Miniatur Wunderland","Fish Market","Reeperbahn","HafenCity","Jungfernstieg Shopping","Planten un Blomen Park"]"#,
         "weekend"),
        ("munich", "Munich", "Munich", "Bavaria", 48.1351, 11.5820,
         "Bavarian capital - Marienplatz, Englischer Garten, Oktoberfest, BMW Museum",
         "South", r#"["Marienplatz & Glockenspiel","Englischer Garten","BMW Welt & Museum","Nymphenburg Palace","Viktualienmarkt Food Market","Hofbräuhaus","Pinakothek Museums","Olympic Park"]"#,
         "weekend"),
        ("cologne", "Cologne", "Cologne", "North Rhine-Westphalia", 50.9375, 6.9603,
         "Rhine city - Cologne Cathedral, Old Town, Chocolate Museum, Carnival",
         "West", r#"["Cologne Cathedral (UNESCO)","Old Town & Heumarkt","Chocolate Museum","Rhine River Cruise","Hohenzollern Bridge Love Locks","Ludwig Museum","Schildergasse Shopping","Belgian Quarter Cafés"]"#,
         "day_trip"),
        ("frankfurt", "Frankfurt", "Frankfurt", "Hesse", 50.1109, 8.6821,
         "Financial hub - Römer, European Central Bank, Palmengarten, Main Tower",
         "Central", r#"["Römer & Old Town","Main Tower Observation","Palmengarten","Zeil Shopping Mile","Kleinmarkthalle Food Hall","Museumsufer (Museum Embankment)","Sachsenhausen Apple Wine Quarter","European Central Bank"]"#,
         "day_trip"),
        ("stuttgart", "Stuttgart", "Stuttgart", "Baden-Württemberg", 48.7758, 9.1829,
         "Auto city - Mercedes-Benz Museum, Porsche Museum, Wilhelma Zoo",
         "South", r#"["Mercedes-Benz Museum","Porsche Museum","Wilhelma Zoo & Botanical Garden","Königstraße Shopping","Schlossplatz","TV Tower (Fernsehturm)","Stuttgart Market Hall","Solitude Palace"]"#,
         "day_trip"),
        ("dusseldorf", "Düsseldorf", "Dusseldorf", "North Rhine-Westphalia", 51.2277, 6.7735,
         "Fashion capital - Königsallee, Rhine promenade, Altstadt, MedienHafen",
         "West", r#"["Königsallee (Kö) Shopping","Altstadt - Longest Bar in the World","MedienHafen Architecture","Rhine Promenade","Kunstpalast Museum","Japanese Quarter","Carlsplatz Market"]"#,
         "day_trip"),
        ("leipzig", "Leipzig", "Leipzig", "Saxony", 51.3397, 12.3731,
         "Music city - Bach Museum, Monument to Battle of Nations, Auerbachs Keller",
         "East", r#"["Bach Museum & Thomaskirche","Monument to Battle of Nations","Auerbachs Keller Restaurant","Mädler Passage","Leipzig Zoo","Spinnerei Art Center","Nikolaikirche","Karl-Liebknecht-Straße Cafés"]"#,
         "day_trip"),
        ("dresden", "Dresden", "Dresden", "Saxony", 51.0504, 13.7373,
         "Florence of the Elbe - Frauenkirche, Semperoper, Zwinger Palace, Green Vault",
         "East", r#"["Frauenkirche","Semperoper Opera House","Zwinger Palace","Green Vault Treasury","Brühl's Terrace","Neustadt Quarter Bars","Elbe River Steamboats","Pillnitz Palace & Gardens"]"#,
         "weekend"),
        ("nuremberg", "Nuremberg", "Nuremberg", "Bavaria", 49.4521, 11.0767,
         "Medieval charm - Imperial Castle, Christmas Market, Albrecht Dürer House",
         "South", r#"["Imperial Castle (Kaiserburg)","Nuremberg Christmas Market","Albrecht Dürer House","Documentation Center","Handwerkerhof Craftsmen's Courtyard","Hauptmarkt Square","German National Museum","Nuremberg Bratwurst"]"#,
         "day_trip"),
        ("hannover", "Hannover", "Hannover", "Lower Saxony", 52.3759, 9.7320,
         "Garden city - Herrenhausen Gardens, New Town Hall, Maschsee Lake",
         "North", r#"["Herrenhausen Royal Gardens","New Town Hall","Maschsee Lake","Eilenriede Urban Forest","Sprengel Museum","Old Town","Hanover Zoo","Linden Quarter"]"#,
         "day_trip"),
        ("bremen", "Bremen", "Bremen", "Bremen", 53.0793, 8.8017,
         "Fairy tale city - Town Musicians, Schnoor Quarter, Böttcherstraße",
         "North", r#"["Town Musicians of Bremen Statue","Schnoor Quarter","Böttcherstraße","Market Square & Town Hall (UNESCO)","St. Peter's Cathedral","Überseestadt","Schlachte Riverbank","Beck's Brewery Tour"]"#,
         "day_trip"),
        ("heidelberg", "Heidelberg", "Heidelberg", "Baden-Württemberg", 49.3988, 8.6724,
         "Romantic city - Heidelberg Castle, Old Bridge, University, Philosopher's Walk",
         "South", r#"["Heidelberg Castle Ruins","Old Bridge (Alte Brücke)","Philosopher's Walk","Hauptstraße Shopping","University of Heidelberg","Church of the Holy Spirit","Bergbahn Funicular","Student Jail (Studentenkarzer)"]"#,
         "day_trip"),
        ("freiburg", "Freiburg", "Freiburg", "Baden-Württemberg", 47.9990, 7.8421,
         "Black Forest gateway - Freiburg Minster, Bächle streams, eco-capital of Germany",
         "South", r#"["Freiburg Minster","Bächle Streams","Schlossberg Hill & Tower","Augustinerplatz","Münstermarkt Daily Market","Black Forest Hikes","Schauinsland Cable Car","Old Town & Konviktstraße"]"#,
         "weekend"),
        ("potsdam", "Potsdam", "Potsdam", "Brandenburg", 52.3906, 13.0645,
         "Royal residences - Sanssouci Palace, Dutch Quarter, Cecilienhof, film studios",
         "East", r#"["Sanssouci Palace & Park (UNESCO)","Dutch Quarter Shops & Cafés","Cecilienhof Palace","Babelsberg Film Studios","Glienicker Bridge","New Palace","Alexandrowka Russian Colony","Biosphere Potsdam"]"#,
         "day_trip"),
        ("mainz", "Mainz", "Mainz", "Rhineland-Palatinate", 49.9929, 8.2473,
         "Wine capital - Gutenberg Museum, St. Martin's Cathedral, Rhine promenade",
         "Central", r#"["Gutenberg Museum","St. Martin's Cathedral","Rhine Promenade","Mainz Carnival","Augustinerstraße Wine Bars","Roman Theatre","State Museum","Christmas Market"]"#,
         "day_trip"),
        ("erfurt", "Erfurt", "Erfurt", "Thuringia", 50.9787, 11.0328,
         "Medieval gem - Krämerbrücke, Cathedral, Petersberg Citadel, EGA Park",
         "Central", r#"["Krämerbrücke (Merchants' Bridge)","Erfurt Cathedral & Severikirche","Petersberg Citadel","EGA Park","Fischmarkt Square","Augustiner Monastery","Old Synagogue","Anger Shopping"]"#,
         "day_trip"),
        ("rostock", "Rostock", "Rostock", "Mecklenburg-Vorpommern", 54.0924, 12.0991,
         "Baltic port - Warnemünde beach, lighthouse, maritime heritage, university",
         "North", r#"["Warnemünde Beach & Lighthouse","Rostock Old Town","St. Mary's Church Astronomical Clock","City Harbor","Kröpeliner Straße Shopping","IGA Park","Warnemünde Fish Market","Baltic Sea Promenade"]"#,
         "weekend"),
        ("kiel", "Kiel", "Kiel", "Schleswig-Holstein", 54.3233, 10.1228,
         "Sailing city - Kieler Woche regatta, fjord, maritime museum, beaches",
         "North", r#"["Kieler Woche Sailing Regatta","Kiel Fjord","Maritime Museum","Laboe Naval Memorial","Holtenau Locks","Kiel Botanical Garden","Falckensteiner Beach","Schrevenpark"]"#,
         "weekend"),
        ("luebeck", "Lübeck", "Lübeck", "Schleswig-Holstein", 53.8655, 10.6866,
         "Hanseatic pearl - Holstentor, marzipan, Buddenbrooks House, Old Town",
         "North", r#"["Holstentor Gate","Niederegger Marzipan Shop","Buddenbrooks House","Old Town (UNESCO)","St. Mary's Church","European Hansemuseum","Travemünde Beach","Café Niederegger"]"#,
         "day_trip"),
        ("augsburg", "Augsburg", "Augsburg", "Bavaria", 48.3705, 10.8978,
         "Renaissance city - Fuggerei, Augsburg Cathedral, Puppet Theatre Museum",
         "South", r#"["Fuggerei (World's Oldest Social Housing)","Augsburg Cathedral","Puppet Theatre Museum","Maximilianstraße","City Hall & Golden Hall","Augsburg Zoo","Botanical Garden","Schaezlerpalais"]"#,
         "day_trip"),
        ("regensburg", "Regensburg", "Regensburg", "Bavaria", 49.0134, 12.1016,
         "Danube gem - Stone Bridge, medieval Old Town, UNESCO World Heritage",
         "South", r#"["Stone Bridge (Steinerne Brücke)","Old Town (UNESCO)","Regensburg Cathedral","Wurstkuchl (Historic Sausage Kitchen)","Thurn und Taxis Palace","Walhalla Memorial","Old Town Hall","Danube River Walk"]"#,
         "day_trip"),
        ("wuerzburg", "Würzburg", "Würzburg", "Bavaria", 49.7913, 9.9534,
         "Wine city - Residence Palace, Old Main Bridge, Marienberg Fortress",
         "Central", r#"["Würzburg Residence (UNESCO)","Old Main Bridge Wine Bars","Marienberg Fortress","Stein Wine Region","Falkenhaus","Juliusspital Weingut","Hofgarten","Franconian Wine Festival"]"#,
         "day_trip"),
        ("konstanz", "Konstanz", "Konstanz", "Baden-Württemberg", 47.6603, 9.1758,
         "Lake Constance - Mainau Island, Swiss border, Old Town, Imperia statue",
         "South", r#"["Mainau Flower Island","Lake Constance (Bodensee)","Imperia Statue","Old Town & Münster","Swiss Border Walk","SEA LIFE Konstanz","Niederburg Quarter","Bike Around the Lake"]"#,
         "weekend"),
        ("trier", "Trier", "Trier", "Rhineland-Palatinate", 49.7490, 6.6371,
         "Oldest city - Porta Nigra, Roman ruins, Karl Marx House, Imperial Baths",
         "West", r#"["Porta Nigra (UNESCO)","Roman Imperial Baths","Karl Marx House","Constantine Basilica","Trier Cathedral","Amphitheatre","Hauptmarkt Square","Moselle Wine Tasting"]"#,
         "day_trip"),
        ("karlsruhe", "Karlsruhe", "Karlsruhe", "Baden-Württemberg", 49.0069, 8.4037,
         "Fan-shaped city - Palace, ZKM art center, Botanical Garden, Federal Court",
         "South", r#"["Karlsruhe Palace & Park","ZKM Center for Art & Media","Botanical Garden","Kaiserstraße Shopping","Federal Constitutional Court","Natural History Museum","Europaplatz","Schlosspark"]"#,
         "day_trip"),
        ("mannheim", "Mannheim", "Mannheim", "Baden-Württemberg", 49.4875, 8.4660,
         "Grid city - Water Tower, Technoseum, Luisenpark, Barockschloss",
         "South", r#"["Water Tower & Friedrichsplatz","Technoseum","Luisenpark","Mannheim Palace (Barockschloss)","Planken Shopping","Jungbusch Quarter","Kunsthalle Museum","BUGA Park"]"#,
         "day_trip"),
        ("bonn", "Bonn", "Bonn", "North Rhine-Westphalia", 50.7374, 7.0982,
         "Former capital - Beethoven House, Museum Mile, Rhine promenade, cherry blossoms",
         "West", r#"["Beethoven House","Museum Mile (Museummeile)","Cherry Blossom Altstadt","Rhine Promenade","Bundeskunsthalle","Poppelsdorf Palace","Haribo Store","Kreuzbergkirche"]"#,
         "day_trip"),
        ("dortmund", "Dortmund", "Dortmund", "North Rhine-Westphalia", 51.5136, 7.4653,
         "Football city - Signal Iduna Park, Westfalenpark, German Football Museum",
         "West", r#"["Signal Iduna Park (BVB Stadium)","German Football Museum","Westfalenpark & TV Tower","Dortmund U-Tower Art Center","Hohensyburg","Rombergpark","Phoenix Lake","Bier Museum"]"#,
         "day_trip"),
        ("essen", "Essen", "Essen", "North Rhine-Westphalia", 51.4556, 7.0116,
         "Culture capital - Zollverein (UNESCO), Villa Hügel, Folkwang Museum",
         "West", r#"["Zeche Zollverein (UNESCO)","Villa Hügel","Museum Folkwang","Baldeneysee Lake","Grugapark","Kettwig Old Town","Limbecker Platz Shopping","Red Dot Design Museum"]"#,
         "day_trip"),
        ("muenster", "Münster", "Münster", "North Rhine-Westphalia", 51.9607, 7.6261,
         "Bicycle city - Prinzipalmarkt, St. Paul's Cathedral, Aasee Lake, Peace Hall",
         "West", r#"["Prinzipalmarkt Historic Arcade","St. Paul's Cathedral","Aasee Lake & Promenade","Peace Hall (Friedenssaal)","LWL Museum","Bicycle Culture Tour","Kiepenkerl Statue","Domplatz Market"]"#,
         "day_trip"),
        ("aachen", "Aachen", "Aachen", "North Rhine-Westphalia", 50.7753, 6.0839,
         "Charlemagne's city - Aachen Cathedral (UNESCO), hot springs, Printen cookies",
         "West", r#"["Aachen Cathedral (UNESCO)","Carolus Thermen Hot Springs","Aachener Printen Bakeries","Town Hall & Charlemagne Treasury","Elisenbrunnen Fountain","Pontstraße Quarter","Ludwig Forum Art","Three-Country Point (DE/NL/BE)"]"#,
         "day_trip"),
        ("bamberg", "Bamberg", "Bamberg", "Bavaria", 49.8988, 10.9028,
         "Beer city - Old Town Hall on river, Bamberg Cathedral, smoked beer, Little Venice",
         "Central", r#"["Old Town Hall on River","Bamberg Cathedral & Horseman","Little Venice (Klein-Venedig)","Schlenkerla Smoked Beer","Rose Garden","Bamberg Symphony","Old Town (UNESCO)","Brewery Tours"]"#,
         "day_trip"),
        ("ulm", "Ulm", "Ulm", "Baden-Württemberg", 48.4011, 9.9876,
         "Einstein's birthplace - Ulm Minster (tallest church), Fisherman's Quarter, Danube",
         "South", r#"["Ulm Minster (Tallest Church Tower)","Fisherman's Quarter (Fischerviertel)","Einstein Fountain & Birth House","Danube Riverfront","Stadtmauer (City Wall Walk)","Kunsthalle Weishaupt","Tiergarten Ulm","Wiblingen Monastery"]"#,
         "day_trip"),
        ("goettingen", "Göttingen", "Göttingen", "Lower Saxony", 51.5328, 9.9352,
         "University town - Gänseliesel fountain, Nobel laureates, half-timbered houses",
         "Central", r#"["Gänseliesel Fountain","Old Town Hall","Half-Timbered Houses","University Quarter","Bismarck Tower","Botanical Garden","Wall Promenade","Nobel Laureate Walk"]"#,
         "day_trip"),
        ("magdeburg", "Magdeburg", "Magdeburg", "Saxony-Anhalt", 52.1205, 11.6276,
         "Elbe city - Green Citadel (Hundertwasser), Cathedral, Waterway Crossroads",
         "East", r#"["Green Citadel of Magdeburg (Hundertwasser)","Magdeburg Cathedral","Waterway Crossroads (Wasserstraßenkreuz)","Elbauenpark & Millennium Tower","Monastery of Our Lady","Old Market","Magdeburg Fortress","Elbe River Promenade"]"#,
         "day_trip"),
        ("halle", "Halle (Saale)", "Halle", "Saxony-Anhalt", 51.4828, 11.9700,
         "Handel's birthplace - Market Church, Francke Foundations, salt heritage",
         "East", r#"["Handel House Museum","Market Church (Red Tower)","Francke Foundations","Giebichenstein Castle","Saale River Walk","Moritzburg Art Museum","Peißnitz Island","Salt Museum"]"#,
         "day_trip"),
        ("chemnitz", "Chemnitz", "Chemnitz", "Saxony", 50.8278, 12.9214,
         "Industrial heritage - Karl Marx Monument, Ore Mountains gateway, art museums",
         "East", r#"["Karl Marx Monument (Nischel)","Museum Gunzenhauser","Ore Mountains Gateway","Schlossberg Castle Church","Petrified Forest","Saxon Industrial Museum","Kaßberg Quarter","Market Square"]"#,
         "day_trip"),
        ("schwerin", "Schwerin", "Schwerin", "Mecklenburg-Vorpommern", 53.6355, 11.4170,
         "Castle city - Schwerin Castle on lake, Cathedral, Old Town, lake district",
         "North", r#"["Schwerin Castle on Lake","Cathedral Tower Viewpoint","State Museum","Schelfstadt Old Town","Seven Lakes Boat Tour","Palace Garden","Pfaffenteich Lake","Old Town Market"]"#,
         "day_trip"),
        ("koblenz", "Koblenz", "Koblenz", "Rhineland-Palatinate", 50.3569, 7.5890,
         "Rhine-Moselle confluence - Deutsches Eck, Ehrenbreitstein Fortress, cable car",
         "West", r#"["Deutsches Eck (Rhine-Moselle Corner)","Ehrenbreitstein Fortress & Cable Car","Rhine River Cruise","Moselle Wine Villages","Old Town & Churches","Stolzenfels Castle","Rhine Gorge (UNESCO)","Schängelbrunnen Fountain"]"#,
         "weekend"),
        ("saarbruecken", "Saarbrücken", "Saarbrücken", "Saarland", 49.2354, 6.9968,
         "French-German fusion - Saarland State Theatre, Ludwigskirche, Völklingen Hütte",
         "West", r#"["Völklingen Ironworks (UNESCO)","Ludwigskirche","Saarland State Theatre","St. Johanner Markt","Saarbrücken Castle","Franco-German Garden","Nauwieser Quarter","Saar River Walk"]"#,
         "day_trip"),
        ("wiesbaden", "Wiesbaden", "Wiesbaden", "Hesse", 50.0782, 8.2398,
         "Spa city - Kurhaus, Neroberg hill, thermal baths, Russian Church",
         "Central", r#"["Kurhaus & Casino","Neroberg Hill & Funicular","Kaiser Friedrich Therme","Russian Orthodox Church","Wilhelmstraße","Kochbrunnen Hot Spring","State Theatre","Schlossplatz"]"#,
         "day_trip"),
        ("bielefeld", "Bielefeld", "Bielefeld", "North Rhine-Westphalia", 52.0302, 8.5325,
         "Teutoburg Forest - Sparrenburg Castle, Dr. Oetker, Art Gallery, hiking",
         "West", r#"["Sparrenburg Castle","Teutoburg Forest Hiking","Dr. Oetker World","Kunsthalle Bielefeld","Old Town","Botanischer Garten","Linen Weaver Monument","Obersee Lake"]"#,
         "day_trip"),
        ("braunschweig", "Braunschweig", "Braunschweig", "Lower Saxony", 52.2689, 10.5268,
         "Lion city - Burgplatz, Herzog Anton Ulrich Museum, Happy Rizzi House",
         "North", r#"["Burgplatz & Lion Statue","Happy Rizzi House","Herzog Anton Ulrich Museum","Magniviertel Quarter","Dankwarderode Castle","Richmond Palace","Schlosspark","Traditional Markets"]"#,
         "day_trip"),
        ("kassel", "Kassel", "Kassel", "Hesse", 51.3127, 9.4797,
         "Documenta city - Bergpark Wilhelmshöhe (UNESCO), Brothers Grimm, Hercules monument",
         "Central", r#"["Bergpark Wilhelmshöhe (UNESCO)","Hercules Monument (Herkules)","Grimmwelt Museum (Brothers Grimm)","Wilhelmshöhe Palace","Water Features Show","Orangerie","Karlsaue Park","Documenta Art Trail"]"#,
         "weekend"),
        ("oldenburg", "Oldenburg", "Oldenburg", "Lower Saxony", 53.1435, 8.2146,
         "Green city - Palace Garden, State Museum, Horst Janssen Museum",
         "North", r#"["Oldenburg Palace & Garden","State Museum","Horst Janssen Museum","Schlossgarten Park","Lambertikirche","Wallstraße Shopping","Botanischer Garten","Dobben Quarter"]"#,
         "day_trip"),
        ("osnabrueck", "Osnabrück", "Osnabrück", "Lower Saxony", 52.2799, 8.0472,
         "Peace city - Peace Hall (Treaty of Westphalia), Cathedral, Felix Nussbaum Museum",
         "West", r#"["Peace Hall (Friedenssaal)","Felix Nussbaum Museum","Osnabrück Cathedral","Old Town","Bürgerpark","Botanischer Garten","Bucksturm Tower","Heger Tor"]"#,
         "day_trip"),
        ("passau", "Passau", "Passau", "Bavaria", 48.5665, 13.4314,
         "Three Rivers city - where Danube, Inn & Ilz meet, St. Stephen's organ, Old Town",
         "South", r#"["Three Rivers Confluence Point","St. Stephen's Cathedral & Organ","Veste Oberhaus Fortress","Old Town Walk","Glass Museum","Inn River Promenade","Ilz Valley Hike","Danube Boat Trip"]"#,
         "weekend"),
        ("stralsund", "Stralsund", "Stralsund", "Mecklenburg-Vorpommern", 54.3151, 13.0900,
         "Baltic gem - Old Town (UNESCO), Ozeaneum, gateway to Rügen island",
         "North", r#"["Old Town (UNESCO)","Ozeaneum Aquarium","Rügen Bridge Gateway","St. Mary's Church Tower","Harbor Promenade","Gorch Fock Ship","Nautineum","Alter Markt Square"]"#,
         "weekend"),
        ("garmisch", "Garmisch-Partenkirchen", "Garmisch-Partenkirchen", "Bavaria", 47.5001, 11.0950,
         "Alpine paradise - Zugspitze, Partnach Gorge, skiing, Olympic Stadium",
         "South", r#"["Zugspitze (Germany's Highest Peak)","Partnach Gorge","Eibsee Lake","Olympic Ski Stadium","Alpspitze Panorama","Ludwigstraße Painted Houses","Wank Mountain","Bavarian Alps Hiking"]"#,
         "weekend"),
        ("darmstadt", "Darmstadt", "Darmstadt", "Hesse", 49.8728, 8.6512,
         "Science city - Mathildenhöhe (UNESCO), TU Darmstadt, Hundertwasser building",
         "Central", r#"["Mathildenhöhe (UNESCO)","Hundertwasser Waldspirale","Hessisches Landesmuseum","Luisenplatz","Rosenhöhe Park","Darmstadt Palace","Prinz-Georg-Garten","Vivarium Zoo"]"#,
         "day_trip"),
        ("erlangen", "Erlangen", "Erlangen", "Bavaria", 49.5897, 11.0120,
         "University city - Schlossgarten, Huguenot heritage, Siemens headquarters",
         "South", r#"["Schlossgarten Palace Garden","Huguenot Quarter","Markgräfliches Theater","Botanischer Garten","Bergkirchweih Festival","Erlangen Palace","University Quarter","Regnitz River Walk"]"#,
         "day_trip"),
    ];

    for (id, name, city, state, lat, lng, desc, region, highlights, trip_type) in &destinations {
        conn.execute(
            "INSERT INTO destinations (id, name, city, state, latitude, longitude, description, region, highlights, trip_type) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)",
            rusqlite::params![id, name, city, state, lat, lng, desc, region, highlights, trip_type],
        )?;
    }

    // ── Connections with ICE comparison data ──
    // Format: (from_station_id, to_destination_id, minutes, transfers, transport_types_json, ice_minutes, ice_price_euros)
    let connections: Vec<(&str, &str, i32, i32, &str, Option<i32>, Option<f64>)> = vec![
        // From Berlin
        ("berlin_hbf", "potsdam", 25, 0, r#"["RE","S_BAHN"]"#, None, None),
        ("berlin_hbf", "hamburg", 165, 1, r#"["RE"]"#, Some(107), Some(32.90)),
        ("berlin_hbf", "leipzig", 75, 0, r#"["RE"]"#, Some(63), Some(24.90)),
        ("berlin_hbf", "dresden", 120, 0, r#"["RE"]"#, Some(120), Some(29.90)),
        ("berlin_hbf", "magdeburg", 95, 0, r#"["RE"]"#, Some(83), Some(22.90)),
        ("berlin_hbf", "rostock", 150, 0, r#"["RE"]"#, None, None),
        ("berlin_hbf", "schwerin", 165, 1, r#"["RE"]"#, Some(109), Some(29.90)),
        ("berlin_hbf", "stralsund", 195, 1, r#"["RE"]"#, Some(169), Some(34.90)),
        ("berlin_hbf", "hannover", 165, 1, r#"["RE"]"#, Some(100), Some(29.90)),
        ("berlin_hbf", "erfurt", 180, 1, r#"["RE"]"#, Some(105), Some(29.90)),
        ("berlin_hbf", "halle", 90, 0, r#"["RE"]"#, Some(72), Some(22.90)),
        ("berlin_hbf", "braunschweig", 135, 1, r#"["RE"]"#, Some(95), Some(27.90)),
        ("berlin_hbf", "chemnitz", 165, 1, r#"["RE"]"#, None, None),
        ("berlin_hbf", "nuremberg", 240, 2, r#"["RE"]"#, Some(168), Some(39.90)),
        ("berlin_hbf", "munich", 330, 2, r#"["RE"]"#, Some(240), Some(54.90)),
        ("berlin_hbf", "cologne", 300, 2, r#"["RE"]"#, Some(254), Some(44.90)),
        ("berlin_hbf", "frankfurt", 300, 2, r#"["RE"]"#, Some(228), Some(44.90)),
        // From Hamburg
        ("hamburg_hbf", "luebeck", 45, 0, r#"["RE"]"#, None, None),
        ("hamburg_hbf", "kiel", 75, 0, r#"["RE"]"#, None, None),
        ("hamburg_hbf", "bremen", 60, 0, r#"["RE"]"#, Some(56), Some(17.90)),
        ("hamburg_hbf", "hannover", 90, 0, r#"["RE"]"#, Some(75), Some(24.90)),
        ("hamburg_hbf", "schwerin", 75, 0, r#"["RE"]"#, None, None),
        ("hamburg_hbf", "rostock", 135, 1, r#"["RE"]"#, None, None),
        ("hamburg_hbf", "berlin", 165, 1, r#"["RE"]"#, Some(107), Some(32.90)),
        ("hamburg_hbf", "oldenburg", 120, 1, r#"["RE"]"#, None, None),
        ("hamburg_hbf", "stralsund", 210, 1, r#"["RE"]"#, Some(169), Some(34.90)),
        ("hamburg_hbf", "braunschweig", 135, 1, r#"["RE"]"#, Some(90), Some(24.90)),
        // From Munich
        ("munich_hbf", "augsburg", 40, 0, r#"["RE","RB"]"#, Some(30), Some(12.90)),
        ("munich_hbf", "nuremberg", 90, 0, r#"["RE"]"#, Some(62), Some(22.90)),
        ("munich_hbf", "regensburg", 90, 0, r#"["RE"]"#, Some(85), Some(22.90)),
        ("munich_hbf", "garmisch", 85, 0, r#"["RB"]"#, None, None),
        ("munich_hbf", "passau", 135, 1, r#"["RE"]"#, Some(115), Some(27.90)),
        ("munich_hbf", "ulm", 90, 0, r#"["RE"]"#, Some(78), Some(22.90)),
        ("munich_hbf", "stuttgart", 150, 1, r#"["RE"]"#, Some(125), Some(29.90)),
        ("munich_hbf", "bamberg", 135, 1, r#"["RE"]"#, Some(105), Some(27.90)),
        ("munich_hbf", "konstanz", 240, 2, r#"["RE","RB"]"#, None, None),
        ("munich_hbf", "berlin", 330, 2, r#"["RE"]"#, Some(240), Some(54.90)),
        ("munich_hbf", "freiburg", 270, 2, r#"["RE"]"#, Some(210), Some(39.90)),
        ("munich_hbf", "erlangen", 100, 0, r#"["RE"]"#, Some(70), Some(22.90)),
        // From Frankfurt
        ("frankfurt_hbf", "mainz", 25, 0, r#"["RE","S_BAHN"]"#, None, None),
        ("frankfurt_hbf", "wiesbaden", 35, 0, r#"["RE","S_BAHN"]"#, None, None),
        ("frankfurt_hbf", "heidelberg", 55, 0, r#"["RE"]"#, Some(48), Some(17.90)),
        ("frankfurt_hbf", "mannheim", 45, 0, r#"["RE"]"#, Some(32), Some(14.90)),
        ("frankfurt_hbf", "darmstadt", 20, 0, r#"["RE","S_BAHN"]"#, None, None),
        ("frankfurt_hbf", "wuerzburg", 75, 0, r#"["RE"]"#, Some(63), Some(22.90)),
        ("frankfurt_hbf", "koblenz", 70, 0, r#"["RE"]"#, Some(55), Some(19.90)),
        ("frankfurt_hbf", "cologne", 90, 1, r#"["RE"]"#, Some(62), Some(22.90)),
        ("frankfurt_hbf", "karlsruhe", 75, 0, r#"["RE"]"#, Some(55), Some(19.90)),
        ("frankfurt_hbf", "kassel", 120, 1, r#"["RE"]"#, Some(90), Some(27.90)),
        ("frankfurt_hbf", "bonn", 105, 1, r#"["RE"]"#, Some(75), Some(24.90)),
        ("frankfurt_hbf", "saarbruecken", 150, 1, r#"["RE"]"#, Some(125), Some(29.90)),
        ("frankfurt_hbf", "trier", 195, 2, r#"["RE"]"#, None, None),
        ("frankfurt_hbf", "stuttgart", 105, 1, r#"["RE"]"#, Some(73), Some(22.90)),
        ("frankfurt_hbf", "nuremberg", 150, 1, r#"["RE"]"#, Some(120), Some(29.90)),
        ("frankfurt_hbf", "freiburg", 150, 1, r#"["RE"]"#, Some(130), Some(29.90)),
        ("frankfurt_hbf", "erfurt", 165, 1, r#"["RE"]"#, Some(115), Some(29.90)),
        ("frankfurt_hbf", "goettingen", 120, 1, r#"["RE"]"#, Some(90), Some(27.90)),
        ("frankfurt_hbf", "hannover", 180, 1, r#"["RE"]"#, Some(135), Some(32.90)),
        ("frankfurt_hbf", "berlin", 300, 2, r#"["RE"]"#, Some(228), Some(44.90)),
        ("frankfurt_hbf", "munich", 240, 2, r#"["RE"]"#, Some(195), Some(39.90)),
        ("frankfurt_hbf", "hamburg", 270, 2, r#"["RE"]"#, Some(210), Some(44.90)),
        // From Cologne
        ("cologne_hbf", "dusseldorf", 25, 0, r#"["RE","S_BAHN"]"#, None, None),
        ("cologne_hbf", "bonn", 20, 0, r#"["RE","S_BAHN"]"#, None, None),
        ("cologne_hbf", "aachen", 55, 0, r#"["RE"]"#, Some(48), Some(17.90)),
        ("cologne_hbf", "dortmund", 50, 0, r#"["RE"]"#, Some(42), Some(17.90)),
        ("cologne_hbf", "essen", 40, 0, r#"["RE"]"#, Some(30), Some(14.90)),
        ("cologne_hbf", "koblenz", 55, 0, r#"["RE"]"#, Some(45), Some(14.90)),
        ("cologne_hbf", "muenster", 90, 1, r#"["RE"]"#, Some(75), Some(24.90)),
        ("cologne_hbf", "bielefeld", 120, 1, r#"["RE"]"#, Some(90), Some(27.90)),
        ("cologne_hbf", "frankfurt", 90, 1, r#"["RE"]"#, Some(62), Some(22.90)),
        ("cologne_hbf", "mainz", 100, 1, r#"["RE"]"#, Some(75), Some(22.90)),
        ("cologne_hbf", "trier", 165, 1, r#"["RE"]"#, None, None),
        // From Stuttgart
        ("stuttgart_hbf", "heidelberg", 50, 0, r#"["RE"]"#, Some(38), Some(14.90)),
        ("stuttgart_hbf", "karlsruhe", 50, 0, r#"["RE"]"#, Some(38), Some(14.90)),
        ("stuttgart_hbf", "ulm", 55, 0, r#"["RE"]"#, Some(42), Some(14.90)),
        ("stuttgart_hbf", "mannheim", 40, 0, r#"["RE"]"#, Some(32), Some(12.90)),
        ("stuttgart_hbf", "freiburg", 120, 1, r#"["RE"]"#, Some(100), Some(27.90)),
        ("stuttgart_hbf", "konstanz", 165, 1, r#"["RE","RB"]"#, None, None),
        ("stuttgart_hbf", "munich", 150, 1, r#"["RE"]"#, Some(125), Some(29.90)),
        ("stuttgart_hbf", "nuremberg", 165, 1, r#"["RE"]"#, Some(130), Some(29.90)),
        ("stuttgart_hbf", "frankfurt", 105, 1, r#"["RE"]"#, Some(73), Some(22.90)),
        // From Hannover
        ("hannover_hbf", "bremen", 65, 0, r#"["RE"]"#, Some(56), Some(17.90)),
        ("hannover_hbf", "hamburg", 90, 0, r#"["RE"]"#, Some(75), Some(24.90)),
        ("hannover_hbf", "berlin", 165, 1, r#"["RE"]"#, Some(100), Some(29.90)),
        ("hannover_hbf", "goettingen", 55, 0, r#"["RE"]"#, Some(38), Some(14.90)),
        ("hannover_hbf", "braunschweig", 40, 0, r#"["RE"]"#, Some(30), Some(12.90)),
        ("hannover_hbf", "bielefeld", 65, 0, r#"["RE"]"#, Some(48), Some(17.90)),
        ("hannover_hbf", "osnabrueck", 75, 0, r#"["RE"]"#, Some(55), Some(17.90)),
        ("hannover_hbf", "magdeburg", 90, 0, r#"["RE"]"#, Some(60), Some(19.90)),
        ("hannover_hbf", "kassel", 75, 0, r#"["RE"]"#, Some(55), Some(17.90)),
        ("hannover_hbf", "oldenburg", 105, 1, r#"["RE"]"#, None, None),
        // From Leipzig
        ("leipzig_hbf", "berlin", 75, 0, r#"["RE"]"#, Some(63), Some(24.90)),
        ("leipzig_hbf", "dresden", 70, 0, r#"["RE"]"#, Some(68), Some(22.90)),
        ("leipzig_hbf", "halle", 25, 0, r#"["RE","S_BAHN"]"#, None, None),
        ("leipzig_hbf", "erfurt", 75, 0, r#"["RE"]"#, Some(45), Some(14.90)),
        ("leipzig_hbf", "chemnitz", 70, 0, r#"["RE"]"#, None, None),
        ("leipzig_hbf", "magdeburg", 75, 0, r#"["RE"]"#, Some(55), Some(17.90)),
        // From Dresden
        ("dresden_hbf", "leipzig", 70, 0, r#"["RE"]"#, Some(68), Some(22.90)),
        ("dresden_hbf", "berlin", 120, 0, r#"["RE"]"#, Some(120), Some(29.90)),
        ("dresden_hbf", "chemnitz", 65, 0, r#"["RE"]"#, None, None),
        // From Nuremberg
        ("nuremberg_hbf", "munich", 90, 0, r#"["RE"]"#, Some(62), Some(22.90)),
        ("nuremberg_hbf", "bamberg", 40, 0, r#"["RE"]"#, Some(35), Some(12.90)),
        ("nuremberg_hbf", "wuerzburg", 60, 0, r#"["RE"]"#, Some(48), Some(17.90)),
        ("nuremberg_hbf", "regensburg", 60, 0, r#"["RE"]"#, Some(50), Some(17.90)),
        ("nuremberg_hbf", "augsburg", 75, 0, r#"["RE"]"#, Some(52), Some(17.90)),
        ("nuremberg_hbf", "erlangen", 15, 0, r#"["RE","S_BAHN"]"#, None, None),
    ];

    for (from_id, to_id, minutes, transfers, types, ice_min, ice_eur) in &connections {
        conn.execute(
            "INSERT INTO connections (from_station_id, to_destination_id, travel_time_minutes, number_of_transfers, transport_types, ice_minutes, ice_price_euros) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)",
            rusqlite::params![from_id, to_id, minutes, transfers, types, ice_min, ice_eur],
        )?;
    }

    // ── Route segments for key connections ──
    let segments: Vec<(&str, &str, i32, &str, &str, &str, &str, i32)> = vec![
        // Berlin → Potsdam (direct)
        ("berlin_hbf", "potsdam", 1, "Berlin Hbf", "Potsdam Hbf", "RE", "RE1", 25),
        // Berlin → Leipzig (direct)
        ("berlin_hbf", "leipzig", 1, "Berlin Hbf", "Leipzig Hbf", "RE", "RE3", 75),
        // Berlin → Dresden (direct)
        ("berlin_hbf", "dresden", 1, "Berlin Hbf", "Dresden Hbf", "RE", "RE50", 120),
        // Berlin → Hamburg (with transfer)
        ("berlin_hbf", "hamburg", 1, "Berlin Hbf", "Wittenberge", "RE", "RE3", 75),
        ("berlin_hbf", "hamburg", 2, "Wittenberge", "Hamburg Hbf", "RE", "RE1", 90),
        // Hamburg → Lübeck
        ("hamburg_hbf", "luebeck", 1, "Hamburg Hbf", "Lübeck Hbf", "RE", "RE80", 45),
        // Hamburg → Kiel
        ("hamburg_hbf", "kiel", 1, "Hamburg Hbf", "Kiel Hbf", "RE", "RE70", 75),
        // Hamburg → Bremen
        ("hamburg_hbf", "bremen", 1, "Hamburg Hbf", "Bremen Hbf", "RE", "RE4", 60),
        // Munich → Augsburg
        ("munich_hbf", "augsburg", 1, "München Hbf", "Augsburg Hbf", "RE", "RE57", 40),
        // Munich → Garmisch
        ("munich_hbf", "garmisch", 1, "München Hbf", "Murnau", "RB", "RB61", 50),
        ("munich_hbf", "garmisch", 2, "Murnau", "Garmisch-Partenkirchen", "RB", "RB61", 35),
        // Munich → Nuremberg
        ("munich_hbf", "nuremberg", 1, "München Hbf", "Nürnberg Hbf", "RE", "RE1", 90),
        // Frankfurt → Mainz
        ("frankfurt_hbf", "mainz", 1, "Frankfurt Hbf", "Mainz Hbf", "S_BAHN", "S8", 25),
        // Frankfurt → Heidelberg
        ("frankfurt_hbf", "heidelberg", 1, "Frankfurt Hbf", "Heidelberg Hbf", "RE", "RE60", 55),
        // Frankfurt → Cologne (with transfer)
        ("frankfurt_hbf", "cologne", 1, "Frankfurt Hbf", "Koblenz Hbf", "RE", "RE2", 55),
        ("frankfurt_hbf", "cologne", 2, "Koblenz Hbf", "Köln Hbf", "RE", "RE5", 35),
        // Cologne → Düsseldorf
        ("cologne_hbf", "dusseldorf", 1, "Köln Hbf", "Düsseldorf Hbf", "RE", "RE1", 25),
        // Cologne → Bonn
        ("cologne_hbf", "bonn", 1, "Köln Hbf", "Bonn Hbf", "RE", "RE5", 20),
        // Cologne → Aachen
        ("cologne_hbf", "aachen", 1, "Köln Hbf", "Aachen Hbf", "RE", "RE1", 55),
        // Cologne → Dortmund
        ("cologne_hbf", "dortmund", 1, "Köln Hbf", "Dortmund Hbf", "RE", "RE1", 50),
        // Stuttgart → Heidelberg
        ("stuttgart_hbf", "heidelberg", 1, "Stuttgart Hbf", "Heidelberg Hbf", "RE", "RE10a", 50),
        // Stuttgart → Ulm
        ("stuttgart_hbf", "ulm", 1, "Stuttgart Hbf", "Ulm Hbf", "RE", "RE5", 55),
        // Hannover → Göttingen
        ("hannover_hbf", "goettingen", 1, "Hannover Hbf", "Göttingen Bhf", "RE", "RE2", 55),
        // Hannover → Braunschweig
        ("hannover_hbf", "braunschweig", 1, "Hannover Hbf", "Braunschweig Hbf", "RE", "RE30", 40),
        // Nuremberg → Bamberg
        ("nuremberg_hbf", "bamberg", 1, "Nürnberg Hbf", "Bamberg Bhf", "RE", "RE1", 40),
        // Nuremberg → Erlangen
        ("nuremberg_hbf", "erlangen", 1, "Nürnberg Hbf", "Erlangen Bhf", "S_BAHN", "S1", 15),
    ];

    for (from_id, to_id, seq, from_stop, to_stop, ttype, line, dur) in &segments {
        conn.execute(
            "INSERT INTO route_segments (from_station_id, to_destination_id, sequence_order, from_stop, to_stop, transport_type, line, duration_minutes) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)",
            rusqlite::params![from_id, to_id, seq, from_stop, to_stop, ttype, line, dur],
        )?;
    }

    tracing::info!("Seeded database with {} stations, {} destinations, {} connections", stations.len(), destinations.len(), connections.len());
    Ok(())
}
