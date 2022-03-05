import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../providers/kids.dart';

class DialogScreens extends StatelessWidget {

  TextEditingController nameController = TextEditingController();
  Kids kids = new Kids();

  dynamic newTask(context, parentId) {
    nameController.text = "";
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Builder(
          builder: (context) {
            // Get available height and width of the build area of this widget. Make a choice depending on the size.
            var height = 0.0; //MediaQuery.of(context).size.height;
            var width = MediaQuery.of(context).size.width;

            return Container(
              height: height,
              width: width - 100,
            );
          },
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text("Új gyerek:"),
        actions: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Neve: ',
            ),
          ),
          Row(
            children: [
              TextButton(
                child: Text("Rögzít"),
                onPressed: () async {
                  await kids.insertKid(nameController.text).then((value) {
                    });
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text("Mégsem"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}