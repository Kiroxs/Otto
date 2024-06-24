import 'dart:convert';
import 'dart:io';
import 'dart:math';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';

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
  String textoPrueba = "PASO";
  double tiempodelpasito = 0;
  bool isBailando = false;
  double terminapaso = 0;
  int index = 0;
  int paso = 0;
  int numeropaso = 0;
  var random = Random();

  List<Cancion> canciones = [
    Cancion("musica/cancion1.mp3", "Amar azul - Yo me enamore", false,
        "No especificado"),
    Cancion("musica/cancion2.mp3", "Homero Simpson - Rosa pastel", false,
        "No especificado"),
    Cancion("musica/cancion3.mp3", "Amar Azul-Tomo Vino y Cerveza", false,
        "No especificado"),
  ];
  List<String> pasos = [
    "MOVE 8 3 1000 30",
    "MOVE 9 3 1000 30",
    "MOVE 4 1 1000 30",
    "MOVE 10 3 1000 30",
    "MOVE 4 1 1000 30",
    "MOVE 1 1 1000 30",
    "MOVE 11 1 1000 30",
    "MOVE 2 1 1000 30",
    "MOVE 6 3 1000 30",
    "MOVE 7 3 1000 30",
    "MOVE 5 3 1000 30",
    "MOVE 20 3 1000 30",
    "MOVE 8 3 1000 30",
    "MOVE 9 1 1000 30",
    "MOVE 13 1 1000 30",
    "MOVE 10 3 1000 30",
    "MOVE 13 1 1000 30",
    "MOVE 17 1 1000 30",
    "MOVE 18 1 1000 30",
    "MOVE 8 3 1000 30",
    
  ];
  @override
  void initState() {
    super.initState();
    requestPermissions();
    loadCanciones();
    if (!mounted) return;
    BluetoothConnection? connection =
        Provider.of<CancionesModel>(context, listen: false).connection;
    player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        isPlaying = state == PlayerState.playing;
        if (state == PlayerState.completed) {
          isBailando == false;
          tiempodelpasito = 0;
          terminapaso = 0;
          currentPosition = 0;
          canciones[index].reproduciendo = false;
          paso = 0;
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

      if (isBailando == false && currentPosition > terminapaso) {
        setState(() {
          isBailando == true;
          tiempodelpasito = position.inMilliseconds.toDouble();
          terminapaso = 200+tiempodelpasito +
              (int.parse(pasos[paso].split(" ")[2])) *
                  (int.parse(pasos[paso].split(" ")[3]));
        });
        print((int.parse(pasos[paso].split(" ")[2]) + 1) *
            (int.parse(pasos[paso].split(" ")[3])));

        connection!.output.add(utf8.encode(pasos[paso] + "\r\n"));
        connection!.output.allSent;
        setState(() {
          if (paso < pasos.length - 1) {
            paso++;
          } else {
            paso = 0;
          }
          isBailando == false;
        });
      }
      if (currentPosition > terminapaso) {
        setState(() {
          isBailando == false;
        });
      }
    });
  }

  Future<void> loadCanciones() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cancionesString = prefs.getStringList('canciones') ?? [];
    List<Cancion> loadedCanciones = cancionesString.map((cancionString) {
      List<String> parts = cancionString.split(',');
      return Cancion(parts[1], parts[0], false, parts[2]);
    }).toList();
    Provider.of<CancionesModel>(context, listen: false)
        .setCanciones(loadedCanciones);
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
        String? selectedGenre =
            'reggaeton'; // Variable para almacenar el género seleccionado inicialmente

        return StatefulBuilder(
          // Agregado para manejar estado dentro del diálogo
          builder: (BuildContext context, StateSetter setState) {
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
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      style: const TextStyle(color: Color(0xff93479b)),
                      underline: Container(
                        height: 2,
                        color: Color(0xff93479b),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          // Aquí se actualiza el estado local del diálogo
                          selectedGenre = newValue;
                        });
                      },
                      items: <String>['reggaeton', 'pop', 'cumbia']
                          .map<DropdownMenuItem<String>>((String value) {
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
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Subir'),
                  onPressed: () async {
                    if (tempFilePath != null) {
                      File file = File(tempFilePath!);
                      Directory appDocDir =
                          await getApplicationDocumentsDirectory();
                      String appDocPath = appDocDir.path;
                      final newFile = await file
                          .copy('$appDocPath/${Path.basename(tempFilePath!)}');
                      Provider.of<CancionesModel>(context, listen: false)
                          .addCancion(Cancion(newFile.path,
                              titleController.text, false, selectedGenre!));
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
                    icon: Icon(Icons.file_upload,
                        size: 35, color: Color(0xff93479b)),
                    onPressed: () =>
                        _showUploadDialog(context), // Abre el modal
                  ),
                ],
              ),
              body: Column(
                children: [
                  Text(textoPrueba + " ${paso}",
                      style: TextStyle(fontSize: 30)),
                  if (Provider.of<CancionesModel>(context, listen: false)
                          .connection ==
                      null)
                    Center(
                        child: Text("NECESITAS CONECTARTE",
                            style: TextStyle(
                                fontSize: 30, color: Color(0xff93479b)))),
                  /* if(Provider.of<CancionesModel>(context, listen: false)
                                .connection!=null)
                  ElevatedButton(
                      onPressed: () async {
                        BluetoothConnection? connection =
                            Provider.of<CancionesModel>(context, listen: false)
                                .connection;

                        try {
                          if (connection != null) {
                            for (var paso in pasos) {
                              connection?.output
                                  .add(utf8.encode(paso + "\r\n"));
                                  await connection?.output.allSent;
                                  
                              await Future.delayed(Duration(
                                  milliseconds:
                                      (int.parse(paso.split(" ")[2])+1)*(int.parse(paso.split(" ")[3]))));
                              setState(() {
                                textoPrueba = paso;
                              });
                              
                                  
                              
                              print("Paso: " + paso);

                             
                            }
                          }
                        } catch (e) {
                          if (kDebugMode) print(e);
                        }
                      },
                      child: Text("BAILAR")), */
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .inversePrimary,
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              cancion.reproduciendo
                                                  ? Icons.graphic_eq
                                                  : Icons.audiotrack,
                                              size: 30,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30.0, vertical: 0),
                                          child: Column(
                                            children: [
                                              Text(
                                                cancion.nombre,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                cancion.genero,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        cancion.reproduciendo
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                      onPressed: () async {
                                        this.index = index;
                                        if (cancion.reproduciendo) {
                                          await player.pause();
                                          setState(() {
                                            cancionesModel.updateReproduciendo(
                                                cancion, false);
                                          });
                                        } else {
                                          await player.setSource(
                                              DeviceFileSource(cancion.url));
                                          await player.resume();
                                          setState(() {
                                            cancionesModel
                                                .updateAllReproduciendo(false);
                                            cancionesModel.updateReproduciendo(
                                                cancion, true);
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        }),
                  ),
                  if (cancionesModel.canciones.isNotEmpty &&
                      cancionesModel.canciones.any((c) => c.reproduciendo))
                    buildPlayerControls(cancionesModel, context, this.index),
                ],
              )),
        );
      },
    );
  }

  Widget buildPlayerControls(
      CancionesModel cancionesModel, BuildContext context, int index) {
    if (index < 0 || index >= cancionesModel.canciones.length) {
      return const SizedBox
          .shrink(); // No hay canción seleccionada o índice fuera de rango
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
            onChanged: (value) {},
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
      ],
    );
  }

  void changeTrack(CancionesModel cancionesModel, int newIndex) {
    setState(() {
      var currentIndex = newIndex; // Actualizar el índice actual
      cancionesModel.updateAllReproduciendo(false);
      cancionesModel.updateReproduciendo(
          cancionesModel.canciones[newIndex], true);
      player.stop();
      player
          .setSource(DeviceFileSource(cancionesModel.canciones[newIndex].url));
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
  BluetoothConnection? connection;
  BluetoothConnection? get getConnection => connection;
  List<Cancion> get canciones => _canciones;
  bool _prueba = false;
  bool get Getprueba => _prueba;
  Future<void> addCancion(Cancion cancion) async {
    _canciones.add(cancion);
    await saveCancionesToPrefs();
    notifyListeners();
  }

  Future<void> setConnection(BluetoothConnection connection) async {
    this.connection = connection;
    notifyListeners();
  }

  Future<void> setPrueba(bool prueba) async {
    this._prueba = prueba;
    print("aaaaa");
    notifyListeners();
  }

  void updateReproduciendo(Cancion cancion, bool reproduciendo) {
    int index = _canciones.indexOf(cancion);
    if (index != -1) {
      _canciones[index].reproduciendo = reproduciendo;
      notifyListeners();
    }
  }

  void setCanciones(List<Cancion> newCanciones) {
    _canciones = newCanciones;
    notifyListeners();
  }

  Future<void> saveCancionesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cancionesString = _canciones
        .map((cancion) => '${cancion.nombre},${cancion.url},${cancion.genero}')
        .toList();
    await prefs.setStringList('canciones', cancionesString);
  }

  void updateAllReproduciendo(bool reproduciendo) {
    for (var cancion in _canciones) {
      cancion.reproduciendo = reproduciendo;
    }
    notifyListeners();
  }
}
