import 'package:flutter/material.dart';

class comoSubirCancion extends StatefulWidget {
  const comoSubirCancion({super.key});

  @override
  State<comoSubirCancion> createState() => _comoSubirCancionState();
}

class _comoSubirCancionState extends State<comoSubirCancion> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      // Asegúrate de ajustar esto
      children: [
        Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: TextStyle(
                    fontSize: 18,
                    ), // Define el color como parte del estilo base
                children: <InlineSpan>[
                  TextSpan(
                      text:
                          "PASO 1:  Pulsar el ícono"),
                  WidgetSpan(
                    child: Icon(Icons.file_upload,
                        size: 30), // Cambia el ícono como necesites
                  ),
                  TextSpan(
                      text:
                          ", para desplegar el apartado de subir música."),
                  
                  
                ],
              ),
            ),
          ),
        ),
        Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
                "PASO 2: Agregar un título para la canción que se desea subir.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.left),
          ),
        ),
        Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
                "PASO 3: Seleccionar un género para la canción (pop, reggaeton o cumbia).",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.left),
          ),
        ),
        Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
                "PASO 4: Para seleccionar una canción a subir, se debe pulsar el botón SELECCIONAR ARCHIVO, debe tener en cuenta que el archivo debe poseer la extensión .mp3",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.left),
          ),
        ),
        Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
                "PASO 5: Presionar el subir para guardar la nueva canción o el botón cancelar para no guardarla.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.left),
          ),
        ),
      ],
    );
  }
}