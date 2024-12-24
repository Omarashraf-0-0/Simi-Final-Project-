import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: BottomSheetExample()));
}



void showWarningPopup(BuildContext context, String title, String message,[String buttonMessage="Continue"]){
  showModalBottomSheet(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(
        top: Radius.circular(30),
        bottom: Radius.circular(30)
    )),
    context: context,
    builder: (BuildContext context) {
      return Container(
        color: Colors.grey[250],
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Prevent expanding unnecessarily
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xffFD8744), // Background color of the circle
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 50, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20), // Space before the button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Adjust the corner radius here
                ),
                backgroundColor: Color(0xffFD8744), // Button color
                minimumSize: Size(260, 50), // Set custom width and height
              ),
              child: Text(
                buttonMessage,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}



class BottomSheetExample extends StatelessWidget {
  const BottomSheetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modal Bottom Sheet Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30)
              )),
              context: context,
              builder: (BuildContext context) {
                return Container(
                  color: Colors.grey[250],
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Prevent expanding unnecessarily
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xff3BBD5E), // Background color of the circle
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Icon(Icons.error_outline, size: 50, color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'title',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(),
                        textAlign: TextAlign.center,
                        
                      ),
                      Text(
                        'message',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20), // Space before the button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // Adjust the corner radius here
                          ),
                          backgroundColor: Color(0xff3BBD5E), // Button color
                          minimumSize: Size(260, 50), // Set custom width and height
                        ),
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )


                    ],
                  ),
                );
              },
            );
          },
          child: Text('Show Bottom Sheet'),
        ),
      ),
    );
  }
}
