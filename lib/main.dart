import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_multiwork/Util/GeradorRotas.dart';


void main() {
  runApp(
    MaterialApp(
    title: "Multiwork",
    localizationsDelegates: [
      // ... app-specific localization delegate[s] here
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [
      Locale("pt", "BR")
    ],
      //home: Inicio(),
    debugShowCheckedModeBanner: false,
    initialRoute: "/",
    onGenerateRoute: GeradorRotas.gerar,
    theme: ThemeData(
        buttonTheme: ButtonThemeData(
            buttonColor: Colors.cyan,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: Colors.white, width: 2)
            ),
        ),
        scaffoldBackgroundColor:Color.fromRGBO(55, 55, 55, 1),
        primaryColor: Colors.cyan,
        colorScheme: ColorScheme(
          primaryVariant: Color.fromRGBO(30, 100, 120, 1),
          primary: Colors.cyan[600],
          surface: Colors.grey[200],
          onSurface: Colors.grey[900],
          secondary: Colors.cyanAccent,
          onBackground: Colors.black,
          onError: Colors.redAccent,
          secondaryVariant: Colors.cyan[900],
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          background: Colors.white,
          error: Colors.black,
          brightness: Brightness.light
        ),
        splashColor: Colors.black12,
        accentColor: Colors.cyan,
        inputDecorationTheme: InputDecorationTheme(
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            errorStyle: TextStyle(fontSize: 15, color: Colors.redAccent),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            isDense: true,
            filled: true,
            fillColor: Color.fromRGBO(250, 250, 250, 1),
            hintStyle: TextStyle(color: Colors.black45),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            )
        ),
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.white
          ),
          brightness: Brightness.dark,
          textTheme: TextTheme(
              headline6: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)
          ),
          actionsIconTheme: IconThemeData(
              color: Colors.white
          )
        )
    ),
  ));
}
