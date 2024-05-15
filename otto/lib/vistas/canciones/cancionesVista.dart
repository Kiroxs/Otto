import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:otto/vistas/canciones/cardcancion.dart';

class cancionesVista extends StatefulWidget {
  const cancionesVista({super.key});

  @override
  State<cancionesVista> createState() => _cancionesVistaState();
}

class _cancionesVistaState extends State<cancionesVista> {
  List<Cancion> canciones = [
    Cancion("url1", "Amar azul", true),
    Cancion("url2", "La sensación del Bloque",false),
    Cancion("url3", "Ahora soy peor",false),
    
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                childAspectRatio: 5.0,
              ),
              itemCount: canciones.length,
              itemBuilder: (context, index) {
                return cardCancion(cancion: canciones[index]);
              },
            ),
          ),
          Slider(
            value: 0.5,
            min: 0,
            max: 1,
            onChanged: (double value) {

            },
          ),
        ],
      )),
    );
  }
}

class Cancion {
  String nombre;
  String url;
  bool reproduciendo;
  Cancion(this.url, this.nombre, this.reproduciendo);
}
