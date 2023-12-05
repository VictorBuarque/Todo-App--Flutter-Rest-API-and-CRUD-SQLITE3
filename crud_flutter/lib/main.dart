import 'package:crud_flutter/screens/todo_list.dart';
import 'package:flutter/material.dart';


// stl: Cria um StatelessWidget básico.
// stf: Cria um StatefulWidget básico.
// stful: Cria um StatefulWidget com métodos predefinidos.
// scaffold: Cria um Scaffold básico.
// col: Cria um Column widget.
// row: Cria um Row widget.
// cont: Cria um Container widget.


void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const TodoListPage(),
    );
  }
}