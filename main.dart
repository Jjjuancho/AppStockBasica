// ignore_for_file: prefer_const_constructors

//Importa el paquete material.dart que tiene las clases necesarias para construir interfaces de usuario en Flutter
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//Importa el paquete con las herramientas para firebase y para firestore
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
//Importa el archivo firebase_options.dart generado cuando configuramos el proyecto en firebase
import 'firebase_options.dart';

void main() {
  // Ejecuta la aplicación, pasando una instancia de MyApp como widget raíz
  runApp(const MyApp());
  iniciarFirebase();
}

//Función para iniciar la conexión de la app con firebase
Future<void> iniciarFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

// Define una clase MyApp StatelessWidget (estática), no tiene estado interno y su apariencia no cambiará
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  // Método build para construir la interfaz de usuario de la aplicación
  Widget build(BuildContext context) {
    // Devuelve un MaterialApp, que es un widget que configura la apariencia y el comportamiento de la aplicación
    return MaterialApp(
      title:
          'Gestión de Stock', // Título de la aplicación que se muestra en la barra de chrome, por ejemplo
      // Define el tema de la aplicación
      theme: ThemeData(
        // Define el esquema de colores de la aplicación, basado en un color inicial púrpura
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Define el widget que se muestra primero al iniciar la aplicación
      home: const MyHomePage(),
    );
  }
}

// Define una clase MyHomePage StatefulWidget, lo que significa que puede tener un estado mutable, su apariencia puede cambiar
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // Crea y devuelve una nueva instancia de _MyHomePageState
  State<MyHomePage> createState() => _MyHomePageState();
}

// Define una clase _MyHomePageState que extiende State<MyHomePage>, que representa el estado mutable de MyHomePage
class _MyHomePageState extends State<MyHomePage> {
  //Definimos variables que usaremos a lo largo de la clase:
  //Por el momento, si bien hay numeros, vamos a declarar todas las variables como string
  String nombreProducto = '';
  String precioProducto = '';
  String cantidadProducto = '';

  @override

  // Método build para construir la interfaz de usuario de la página de inicio
  Widget build(BuildContext context) {
    // Devuelve un Scaffold, que proporciona una estructura básica de la interfaz de usuario de la aplicación
    return Scaffold(

        // Define la barra de la aplicación
        appBar: AppBar(
          // Define el color de fondo de la barra
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,

          // Título de la barra
          title: const Text('Gestión de productos'),
        ),
        body: Column(
          // Organiza los elementos en una columna
          children: [
            // Lista de widgets hijos que se mostrarán en la columna
            // Un SizedBox con altura 20 para dar espacio entre los elementos
            SizedBox(height: 20),

            // Un botón elevado con texto "Agregar producto" que ejecuta mostrarCuadroAgregarProducto() cuando se presiona
            ElevatedButton(
                onPressed: () {
                  mostrarCuadroAgregarProducto();
                },
                child: Text('Agregar producto')),

            // Otro SizedBox con altura 20 para dar espacio
            SizedBox(height: 20),

            //Un expanded ocupa el resto del espacio disponible
            Expanded(
              // StreamBuilder es un widget que observa un Stream
              // y reconstruye su interfaz de usuario cada vez que el Stream emite un evento.
              child: StreamBuilder(

                  // Obersarvamos los documentos de la colección 'productos' de la db
                  // Emite un evento cada vez que hay cambios en los documentos de la colección
                  stream: FirebaseFirestore.instance
                      .collection('productos')
                      .snapshots(),

                  // Cuando el Stream emite un evento, StreamBuilder llama a su constructor
                  // de builder con un nuevo AsyncSnapshot 'snapshot' que contiene el último valor emitido
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    // Un ListViewBuilder se usa para construir una lista de elementos
                    return ListView.builder(
                      // Especifica la cantidad total de elementos que se espera que tenga la lista
                      // Nosotros ponemos la cantidad de documentos que tenga la colección
                      itemCount: snapshot.data!.docs.length,

                      // Esta función se llama para construir cada elemento de la lista
                      // Recibe dos parametros, el contexto y el índice del elementto de la lista (documento )que se esta construyendo
                      itemBuilder: (context, index) {
                        //por cada documento, guardamos el documento en 'producto'
                        var producto = snapshot.data!.docs[index];

                        //ListTile se usa para representar una fila en una lista
                        return ListTile(
                          //Mostrar el nombre del producto como titulo
                          title: Text(producto['nombre']),

                          //Mostramos el resto de campos como subtítulos
                          subtitle: Text(
                              'Precio: ${producto['precio']}, Cantidad: ${producto['cantidad']}'),
                        );
                      },
                    );
                  }),
            ),
          ],
        ));
  }

  //Definimos una funcion vacía porque no devuelve nada
  //Esta función muestra un cuadro para completar los datos del producto a agregar
  //Llamaremos a esta función al presionar el botón 'Agregar producto'
  void mostrarCuadroAgregarProducto() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        //Devuelve un alertdialog, es un como un alert de javascript, que tiene un titulo, contenido y acciones
        return AlertDialog(
          //Define el titulo del alertdialog
          title: Text('Agregar nuevo producto'),
          //Define el contenido del alertdialog como una columna
          content: Column(
            //Define el tamaño de la columna con el minimo necesario
            mainAxisSize: MainAxisSize.min,
            children: [
              //Genera un campo de texto para que el usuario ingrese un texto
              TextFormField(
                //Define la label del campo de texto
                decoration: InputDecoration(labelText: 'Nombre del producto'),
                //Cuando el valor del campo de texto cambia, se lo asigna a la variable nombreProducto
                onChanged: (value) => nombreProducto = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Precio'),
                onChanged: (value) => precioProducto = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Cantidad'),
                onChanged: (value) => cantidadProducto = value,
              ),
            ],
          ),
          actions: [
            // Define los botones de acción del cuadro de diálogo
            TextButton(
              // Cuando se presiona 'Agregar', llama a la función agregarProductoFirebase
              onPressed: () {
                agregarProductoFirebase();
              },
              child: Text('Agregar'),
            ),
            TextButton(
              // Cuando se presionar 'Cancelar', cierra el cuadro de diálogo y vuelve al contexto anterior
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  //Definimos una funcion vacía porque no devuelve nada
  //Esta función agrega el producto a la base de datos
  //Llamaremos a esta función al presionar el botón 'Agregar' del formulario del cuadro de dialogo
  Future<void> agregarProductoFirebase() async {
    //En la colección productos, agrega un documento completando los campos con las variables
    await FirebaseFirestore.instance.collection('productos').add({
      'nombre': nombreProducto,
      'precio': precioProducto,
      'cantidad': cantidadProducto,
    });
    //Cierra el cuadro de diálogo de donde venimos
    Navigator.of(context).pop();
  }
}
