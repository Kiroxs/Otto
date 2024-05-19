import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class cancionesVista extends StatefulWidget {
  const cancionesVista({super.key});

  @override
  State<cancionesVista> createState() => _cancionesVistaState();
}

class _cancionesVistaState extends State<cancionesVista> {
  final player = AudioPlayer();
  bool isPlaying = false;
  double currentPosition = 0;
  double totalDuration = 0;
  int duracionMinutos = 0;
  double duracionSegundos = 0;
  int index = 0;
  List<Cancion> canciones = [
    Cancion("musica/cancion1.mp3", "Amar azul - Yo me enamore", false),
    Cancion("musica/cancion2.mp3", "Homero Simpson - Rosa pastel", false),
    Cancion("musica/cancion3.mp3", "Amar Azul-Tomo Vino y Cerveza", false),
  ];

  @override
  void initState() {
    super.initState();
    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
        if (state == PlayerState.completed) {
          canciones[index].reproduciendo = false;
        }
        
      });
    });

    player.onDurationChanged.listen((duration) {
      setState(() {
        totalDuration = duration.inMilliseconds.toDouble();
        
      });
    });

    player.onPositionChanged.listen((position) {
      setState(() {
        currentPosition = position.inMilliseconds.toDouble();
      });
    });
  }

  String formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).round();
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

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
                        if (canciones[index].reproduciendo)
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
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
                        if (!canciones[index].reproduciendo)
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
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
                            canciones[index].nombre,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),

                        if (canciones[index].reproduciendo)
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                print("object");
                                await player.pause();
                                setState(() {
                                  canciones[index].reproduciendo = false;
                                });
                              },
                              child: Icon(
                                Icons.pause,
                                size: 20,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        if (!canciones[index].reproduciendo)
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                await player.setSource(
                                    AssetSource(canciones[index].url));
                                await player.resume();
                                setState(() {
                                  for (var i = 0; i < canciones.length; i++) {
                                    canciones[i].reproduciendo = false;
                                  }
                                  this.index = index;
                                  canciones[index].reproduciendo = true;
                                });
                              },
                              child: Icon(
                                Icons.play_arrow,
                                size: 20,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
          ),
          Text(
            canciones[index].nombre,
            style: TextStyle(
                color: Color(0xff93479b),
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Color(0xff93479b),
              inactiveTrackColor: Colors.red[100],
              trackShape: RoundedRectSliderTrackShape(),
              trackHeight: 4.0,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
              thumbColor: Color(0xff93479b),
              overlayColor: Color(0xff93479b),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
            ),
            child: Slider(
              min: 0,
              max: totalDuration,
              value: currentPosition < totalDuration ? currentPosition : 0,
              onChanged: (value) {
                setState(() {
                  currentPosition = value;
                });
                player.seek(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
          Text(
            "${formatTime(currentPosition.toInt())} / ${formatTime(totalDuration.toInt())}",
            style: TextStyle(
                color: Color(0xff93479b),
                fontWeight: FontWeight.bold,
                fontSize: 20),
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
