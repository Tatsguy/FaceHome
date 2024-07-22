import 'dart:io';

import 'package:face_net_authentication/pages/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class Profile extends StatelessWidget {
  const Profile(this.username, {Key? key, required this.imagePath})
      : super(key: key);
  final String username;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(File(imagePath)),
                      ),
                    ),
                    margin: EdgeInsets.all(20),
                    width: 50,
                    height: 50,
                  ),
                  Text(
                    'Hola ' + username + '!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(20.0),
                child: Table(
                  children: [
                    TableRow(
                      children: [
                        TableCell(
                            child: AppButton(
                          color: Colors.blueAccent,
                          icon: Icon(Icons.door_back_door, color: Colors.white,),
                        )),
                        TableCell(
                            child: AppButton(
                          color: Colors.black54,
                          icon: Icon(Icons.door_back_door),
                        )),
                      ],
                    ),
                    // Add more rows and cells as needed
                  ],
                ),
              ),
              AppButton(
                color: Colors.redAccent,
                icon: Icon(Icons.door_back_door, color: Colors.white,),
              ),
              Spacer(),
              AppButton(
                text: "Salir",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                },
                icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                color: Color(0xFFFF6161),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
