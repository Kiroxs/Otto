import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:otto/vistas/conexion/conexionVista.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;
import 'package:provider/provider.dart';

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
    Cancion("musica/cancion1.mp3", "Amar azul - Yo me enamore", false,
        "No especificado"),
    Cancion("musica/cancion2.mp3", "Homero Simpson - Rosa pastel", false,
        "No especificado"),
    Cancion("musica/cancion3.mp3", "Amar Azul-Tomo Vino y Cerveza", false,
        "No especificado"),
  ];

  @override
  void initState() {
    super.initState();
    requestPermissions();
    player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        isPlaying = state == PlayerState.playing;
        if (state == PlayerState.completed) {
          canciones[index].reproduciendo = false;
        }
      });
    });

    player.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() {
        totalDuration = duration.inMilliseconds.toDouble();
      });
    });

    player.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() {
        currentPosition = position.inMilliseconds.toDouble();
      });
    });
  }

  Future<void> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  String? selectedFilePath;
  String formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).round();
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String? tempFilePath; // Variable temporal para almacenar la ruta del archivo

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null) {
      tempFilePath = result.files.single.path; // Solo guarda la ruta aquí
      print("Archivo seleccionado: $tempFilePath");
    } else {
      print("Selección de archivo cancelada");
      tempFilePath = null;
    }
  }

 void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // Permite cerrar el diálogo al tocar fuera de él
      builder: (BuildContext context) {
        TextEditingController titleController = TextEditingController();
        String? selectedGenre; // Variable para guardar el género seleccionado

        // Lista de géneros disponibles
        List<String> genres = ['reggaeton', 'cumbia', 'pop'];

        return StatefulBuilder( // Añadido para actualizar el estado del diálogo
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Cargar Archivo de Audio'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Título',
                      ),
                    ),
                    SizedBox(height: 20),
                    DropdownButton<String>(
                      value: selectedGenre,
                      hint: Text('Seleccione un género'), // Mensaje cuando no hay selección
                      onChanged: (String? newValue) {
                        setState(() { // Actualiza el estado del diálogo para reflejar la selección
                          selectedGenre = newValue;
                        });
                      },
                      items: genres.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Icon(Icons.folder_open),
                      label: Text('Seleccionar Archivo'),
                      onPressed: () {
                        _pickFile(); // Método ya definido para seleccionar archivos
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xff93479b),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context). pop();
                  },
                ),
                TextButton(
                  child: Text('Subir'),
                  onPressed: () async {
                    if (tempFilePath != null && selectedGenre != null) {
                      print("Subiendo archivo desde: $tempFilePath");
                      File file = File(tempFilePath!);
                      Directory appDocDir = await getApplicationDocumentsDirectory();
                      String appDocPath = appDocDir.path;
                      final newFile = await file.copy('$appDocPath/${Path.basename(tempFilePath!)}');
                      print("Archivo copiado a: ${newFile.path}");

                      // Agregar la canción al modelo global
                      Provider.of<CancionesModel>(context, listen: false)
                          .addCancion(Cancion(newFile.path, titleController.text, false, selectedGenre!));
                      print("Canción agregada al modelo con título: ${titleController.text} y género: $selectedGenre");

                      Navigator.of(context). pop(); // Cierra el diálogo
                    } else {
                      print("No hay archivo seleccionado o no se ha seleccionado un género");
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
Widget build(BuildContext context) {
  return Consumer<CancionesModel>(
    builder: (context, cancionesModel, child) {
      return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.file_upload, size: 35, color: Color(0xff93479b)),
                  onPressed: () => _showUploadDialog(context), // Abre el modal
                ),
              ],
            ),
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
                      itemCount: cancionesModel.canciones.length,
                      itemBuilder: (context, index) {
                        Cancion cancion = cancionesModel.canciones[index];
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
                                    cancion.reproduciendo ? Icons.graphic_eq : Icons.audiotrack,
                                    size: 30,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 26),
                              Expanded(
                                child: Text(
                                  cancion.nombre,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  cancion.reproduciendo ? Icons.pause : Icons.play_arrow,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                onPressed: () async {
                                  if (cancion.reproduciendo) {
                                    await player.pause();
                                    cancionesModel.updateReproduciendo(cancion, false);
                                  } else {
                                    await player.setSource(DeviceFileSource(cancion.url));
                                    await player.resume();
                                    cancionesModel.updateAllReproduciendo(false);
                                    cancionesModel.updateReproduciendo(cancion, true);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                ),
                if (cancionesModel.canciones.isNotEmpty && cancionesModel.canciones.any((c) => c.reproduciendo))
                  buildPlayerControls(cancionesModel, context),
              ],
            )),
      );
    },
  );
}

Widget buildPlayerControls(CancionesModel cancionesModel, BuildContext context) {
  if (index < 0 || index >= cancionesModel.canciones.length) {
    return SizedBox.shrink();  // No hay canción seleccionada o índice fuera de rango
  }

  Cancion currentSong = cancionesModel.canciones[index];

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          currentSong.nombre,
          style: TextStyle(
            color: Color(0xff93479b),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
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
          fontSize: 20,
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.skip_previous, color: Color(0xff93479b), size: 40),
            onPressed: () => changeTrack(cancionesModel, index - 1 < 0 ? cancionesModel.canciones.length - 1 : index - 1),
          ),
          IconButton(
            icon: Icon(currentSong.reproduciendo ? Icons.pause : Icons.play_arrow, color: Color(0xff93479b), size: 40),
            onPressed: () {
              if (currentSong.reproduciendo) {
                player.pause();
                cancionesModel.updateReproduciendo(currentSong, false);
              } else {
                player.setSource(DeviceFileSource(currentSong.url));
                player.resume();
                cancionesModel.updateReproduciendo(currentSong, true);
              }
              setState(() {
                isPlaying = !isPlaying;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.skip_next, color: Color(0xff93479b), size: 40),
            onPressed: () => changeTrack(cancionesModel, index + 1 >= cancionesModel.canciones.length ? 0 : index + 1),
          ),
        ],
      ),
    ],
  );
}


void changeTrack(CancionesModel cancionesModel, int newIndex) {
  setState(() {
    var currentIndex = newIndex;  // Actualizar el índice actual
    cancionesModel.updateAllReproduciendo(false);
    cancionesModel.updateReproduciendo(cancionesModel.canciones[newIndex], true);
    player.stop();
    player.setSource(DeviceFileSource(cancionesModel.canciones[newIndex].url));
    player.resume();
  });
}

}

class Cancion {
  String nombre;
  String url;
  bool reproduciendo;
  String genero; // Añadido para guardar el género de la canción
  Cancion(this.url, this.nombre, this.reproduciendo, this.genero);
}

class CancionesModel extends ChangeNotifier {
  List<Cancion> _canciones = [];

  List<Cancion> get canciones => _canciones;

  void addCancion(Cancion cancion) {
    _canciones.add(cancion);
    notifyListeners();
  }
  void updateReproduciendo(Cancion cancion, bool reproduciendo) {
    int index = _canciones.indexOf(cancion);
    if (index != -1) {
      _canciones[index].reproduciendo = reproduciendo;
      notifyListeners();
    }
  }

  void updateAllReproduciendo(bool reproduciendo) {
    for (var cancion in _canciones) {
      cancion.reproduciendo = reproduciendo;
    }
    notifyListeners();
  }
}
