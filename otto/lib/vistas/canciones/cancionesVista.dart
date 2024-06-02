import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:otto/vistas/conexion/conexionVista.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;


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
      barrierDismissible:
          true, // Permite cerrar el diálogo al tocar fuera de él
      builder: (BuildContext context) {
        TextEditingController titleController = TextEditingController();
        TextEditingController descriptionController = TextEditingController();
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
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Descripción',
                  ),
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
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Subir'),
              onPressed: () async {
                if (tempFilePath != null) {
                  File file = File(tempFilePath!);

                  // Obtener el directorio de documentos de la aplicación
                  Directory appDocDir =
                      await getApplicationDocumentsDirectory();
                  String appDocPath = appDocDir.path;

                  // Copiar el archivo seleccionado al directorio de documentos
                  final newFile = await file
                      .copy('$appDocPath/${Path.basename(tempFilePath!)}');
                  print("Archivo guardado en: ${newFile.path}");

                  // Actualizar la lista de canciones
                  setState(() {
                    canciones.add(Cancion(
                        newFile.path, Path.basename(tempFilePath!), false));
                  });

                  Navigator.of(context).pop(); // Cierra el diálogo
                } else {
                  print("No hay archivo seleccionado");
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            actions: <Widget>[
              IconButton(
                icon:
                    Icon(Icons.file_upload, size: 35, color: Color(0xff93479b)),
                onPressed: () => _showUploadDialog(context), // Abre el modal
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: GridView.builder(
                    padding: EdgeInsets.all(0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                        margin:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 0),
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.graphic_eq,
                                    size: 30,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            if (!canciones[index].reproduciendo)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.audiotrack,
                                    size: 30,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
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
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            if (!canciones[index].reproduciendo)
                              Padding(
                                padding: EdgeInsets.all(20.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Usar DeviceFileSource para cargar el archivo desde el sistema de archivos
                                    await player.setSource(
                                        DeviceFileSource(canciones[index].url));
                                    await player.resume();
                                    setState(() {
                                      for (var i = 0;
                                          i < canciones.length;
                                          i++) {
                                        canciones[i].reproduciendo = false;
                                      }
                                      this.index = index;
                                      canciones[index].reproduciendo = true;
                                    });
                                  },
                                  child: Icon(
                                    Icons.play_arrow,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
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
              if (canciones[index].reproduciendo)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous,
                          color: Color(0xff93479b), size: 40),
                      color: Color(0xff93479b),
                      onPressed: () async {
                        setState(() {
                          if (index > 0) {
                            index--;
                          } else {
                            index = canciones.length - 1;
                          }
                          for (var i = 0; i < canciones.length; i++) {
                            canciones[i].reproduciendo = false;
                          }
                          canciones[index].reproduciendo = true;
                        });

                        await player.stop();
                        await player.play(AssetSource(canciones[index].url));
                      },
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Color(0xff93479b), size: 40),
                      color: Color(0xff93479b),
                      onPressed: () async {
                        if (isPlaying) {
                          await player.pause();
                          setState(() {
                            canciones[index].reproduciendo = false;
                            isPlaying = false;
                          });
                        } else {
                          await player.resume();
                          setState(() {
                            isPlaying = true;
                          });
                        }
                      },
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.skip_next,
                          color: Color(0xff93479b), size: 40),
                      color: Color(0xff93479b),
                      onPressed: () async {
                        setState(() {
                          if (index < canciones.length - 1) {
                            index++;
                          } else {
                            index = 0;
                          }
                          for (var i = 0; i < canciones.length; i++) {
                            canciones[i].reproduciendo = false;
                          }
                          canciones[index].reproduciendo = true;
                        });
                        await player.stop();
                        await player.play(AssetSource(canciones[index].url));
                      },
                    ),
                  ],
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
              if (canciones[index].reproduciendo)
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
