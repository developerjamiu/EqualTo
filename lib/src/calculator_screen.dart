import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:clay_containers/clay_containers.dart';

import 'calculator_viewmodel.dart';

class CalculatorScreen extends StatelessWidget {
  final Color baseColor = Color(0xFFCED4CA);
  final Color screenColor = Color(0xFF899183);
  final Color shadowColor = Color(0xDD899183);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double verticalSpacing = screenHeight / 25;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: baseColor,
        body: SafeArea(
          child: ChangeNotifierProvider(
            create: (context) => CalculatorViewModel(),
            child: Consumer<CalculatorViewModel>(
              builder: (context, model, _) {
                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      appTitle(model),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          model.speech.hasError || model.speech.isListening
                              ? Card(
                                  color: Colors.red.shade900,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      model.lastError,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                              : Container(),
                          Text(model.lastWords,
                              style: TextStyle(fontSize: 24.0)),
                        ],
                      ),
                      SizedBox(height: 16),
                      calculatorScreen(model),
                      SizedBox(height: verticalSpacing),
                      calculatorControls(model),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget appTitle(CalculatorViewModel model) {
    return Row(
      children: [
        Image.asset('assets/images/icon.png', height: 42.0),
        SizedBox(width: 8.0),
        Text(
          'Equalto',
          style: TextStyle(
            fontSize: 36.0,
            fontWeight: FontWeight.w100,
          ),
        ),
        Spacer(),
        Text(model.lastStatus),
        SizedBox(width: 4.0),
        FloatingActionButton(
          child: Icon(Icons.mic, color: Colors.black54),
          backgroundColor: Colors.amber,
          mini: true,
          onPressed: model.startListening,
        ),
      ],
    );
  }

  Widget calculatorScreen(CalculatorViewModel model) {
    return ClayContainer(
      parentColor: Colors.grey.shade600,
      height: 70,
      width: double.infinity,
      borderRadius: 8,
      spread: 3,
      surfaceColor: screenColor,
      curveType: CurveType.none,
      child: Center(
        child: Container(
          padding: EdgeInsets.only(right: 16.0),
          width: double.infinity,
          child: Text(
            model.calculatorModel.displayValue,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 48.0,
              fontFamily: 'Calculator',
            ),
          ),
        ),
      ),
    );
  }

  Widget calculatorControls(CalculatorViewModel model) {
    return StaggeredGridView.countBuilder(
      shrinkWrap: true,
      crossAxisCount: 4,
      itemCount: 18,
      itemBuilder: (BuildContext context, int index) => ClayContainer(
        color: index == 17 ? Colors.amber : baseColor,
        spread: index == 17 ? 0 : 6,
        curveType: index == 17 ? CurveType.convex : CurveType.none,
        borderRadius: 50,
        child: SizedBox.expand(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                model.operation(index);
              },
              splashColor: Colors.grey,
              child: Center(
                child: Text(
                  model.buttonText(index),
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
            ),
          ),
        ),
      ),
      staggeredTileBuilder: (int index) =>
          StaggeredTile.count(index == 1 || index == 15 ? 2 : 1, 1),
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
    );
  }
}
