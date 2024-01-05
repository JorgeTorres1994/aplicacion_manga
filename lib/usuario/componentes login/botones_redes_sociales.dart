import 'package:flutter/material.dart';

class BotonesRedesSociales extends StatelessWidget{
  final String imagePath;
  final Function()? onTap;
  const BotonesRedesSociales({
    super.key,
    required this.imagePath, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        color: Colors.grey[200],
      ),
      child: Image.asset(
        imagePath,
        height: 40,
      ),
    ),
    );
  }

}