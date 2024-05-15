import 'package:flutter/material.dart';
import 'package:otto/vistas/conexion/cardconexion.dart';

class conexionVista extends StatefulWidget {
  const conexionVista({super.key});

  @override
  State<conexionVista> createState() => _conexionVistaState();
}

class _conexionVistaState extends State<conexionVista> {
  List<Robot> robots = [
    Robot("robot1", "Conectado"),
    Robot("robot2", "Desconectado"),
    Robot("robot3", "Desconectado"),
    Robot("robot4", "Desconectado"),
    Robot("robot5", "Desconectado"),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  border: Border.all(
                    color: Color(0xff93479b),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_arrow,
                    size: 50,
                    color: Color(0xff93479b),
                  ),
                ),
              ),
              SizedBox(height: 26),
              Text(
                "CONECTAR",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 26),
              
            ],
          ),
        ),
      ),
    );
  }
}

class Robot {
  String nombre;
  String estado;
  Robot(this.nombre, this.estado);
}
