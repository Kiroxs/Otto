import 'package:flutter/material.dart';
import 'package:otto/vistas/conexion/conexionVista.dart';

class cardConexion extends StatefulWidget {
  const cardConexion({super.key, required this.robot});
  final Robot robot;
  @override
  State<cardConexion> createState() => _cardConexionState();
}

class _cardConexionState extends State<cardConexion> {
  
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
                Icons.adb,
                size: 30,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          SizedBox(width: 26),
          Text(
            widget.robot.nombre,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            widget.robot.estado,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          
        ],
      ),
    );
  }
}