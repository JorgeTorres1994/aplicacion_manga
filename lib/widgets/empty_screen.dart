import 'package:aplicacion_manga/inner_screens/feed_screens.dart';
import 'package:aplicacion_manga/services/global_methods.dart';
import 'package:aplicacion_manga/services/utils.dart';
import 'package:aplicacion_manga/widgets/textos_widget.dart';
import 'package:flutter/material.dart';

class EmptyScreen extends StatelessWidget {
  const EmptyScreen(
      {Key? key,
      required this.imagePath,
      required this.title,
      required this.subtitle,
      required this.buttonText})
      : super(key: key);
  final String imagePath, title, subtitle, buttonText;

  @override
  Widget build(BuildContext context) {
    final Color color = Utils(context).color;
    final themeState = Utils(context).getTheme;
    Size size = Utils(context).getScreenSize;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 25,
              ),
              Image.asset(
                imagePath,
                width: double.infinity,
                height: size.height * 0.4,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Ups...',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextosWidget(
                  text: title,
                  //text: 'No tienes mangas en el carrito',
                  color: Colors.cyan,
                  textSize: 20),
              SizedBox(
                height: size.height * 0.1,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        //color: Theme.of(context).colorScheme.secondary,
                        color: color,
                      )),
                  primary: Theme.of(context).colorScheme.secondary,
                  //onPrimary: color,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  /*textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),*/
                ),
                onPressed: () {
                  GlobalMethods.navigateto(
                      ctx: context, routeName: FeedScreens.routeName);
                },
                child: TextosWidget(
                  text: buttonText,
                  color: themeState ? Colors.white : Colors.black,
                  textSize: 20,
                  isTitle: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
