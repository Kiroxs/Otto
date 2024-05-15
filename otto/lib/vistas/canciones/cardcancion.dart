import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:otto/vistas/canciones/cancionesVista.dart';

class cardCancion extends StatefulWidget {
  final Cancion cancion;
  const cardCancion({super.key, required this.cancion});

  @override
  State<cardCancion> createState() => _cardCancionState();
}

class _cardCancionState extends State<cardCancion> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff93479b),
        borderRadius: BorderRadius.circular(1),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Ícono redondo similar a una imagen de perfil
          if (widget.cancion.reproduciendo)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.inversePrimary,
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.graphic_eq,
                size: 30,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          if (!widget.cancion.reproduciendo)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.inversePrimary,
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.audiotrack,
                size: 30,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          SizedBox(width: 26),
          Expanded(
            
            child: Text(
              widget.cancion.nombre,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10),
          
          if (widget.cancion.reproduciendo)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.pause,
                    size: 20,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
            if (!widget.cancion.reproduciendo)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_arrow,
                    size: 20,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
            
        ],
      ),
    );
  }
}
