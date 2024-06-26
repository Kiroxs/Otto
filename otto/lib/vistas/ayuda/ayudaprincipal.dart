import 'package:flutter/material.dart';
import 'package:otto/vistas/ayuda/comoconectarse.dart';
import 'package:otto/vistas/ayuda/comosubircancion.dart';


class ayudaPrincipal extends StatefulWidget {
  const ayudaPrincipal({super.key});

  @override
  State<ayudaPrincipal> createState() => _ayudaPrincipalState();
}

class _ayudaPrincipalState extends State<ayudaPrincipal> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
              child: Text(
                "AYUDA Y SOPORTE",
                style: TextStyle(
                    fontSize: 30,
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentPageIndex = 0;
                          });
                        },
                        child: Text("Conexión")),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentPageIndex = 1;
                          });
                        },
                        child: Text("Subir canción")),
                    
                  ],
                ),
              ],
            ),
            if (currentPageIndex == 0)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal:15),
                  child: ComoConectar(),
                ),
              ),
            if(currentPageIndex == 1)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal:15),
                  child: comoSubirCancion(),
                 ),
              ),
          ],
        ),
      ),
    ));
  }
}
