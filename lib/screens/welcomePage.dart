import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ocaviva/main.dart';
import 'package:ocaviva/models/firestore.dart';
import 'package:ocaviva/models/usuario.dart';
import 'package:ocaviva/screens/home_page.dart';
import 'package:ocaviva/screens/loginPage.dart';
import 'package:ocaviva/screens/registroPage.dart';
import 'package:ocaviva/widgets/bodyBackground.dart';
import 'package:ocaviva/widgets/botao.dart';
import 'package:ocaviva/widgets/texto.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/jogo_service.dart';
import 'package:path_provider/path_provider.dart';

final GlobalKey<State> _keyLoader = new GlobalKey<State>();
SharedPreferences prefs;
class WelcomePage extends StatefulWidget
{
  @override
  WelcomeState createState() {
    return new WelcomeState();
  }
}

class WelcomeState extends State<WelcomePage>
{
  @override
  void initState() 
  {
    super.initState();
    userAuth = Mobxfirestore();
    //checkFirstSeen();
    new Timer(new Duration(milliseconds: 200), () {
    checkFirstSeen();
    });
  }

  @override
  Widget build(BuildContext context) 
  {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    String fraseInicial = "Olá,  \nvejo que é a sua primeira\n vez aqui\n Vamos começar!\n\n Se não possui conta, então:\n";
    return  FutureBuilder(
                  future: abrirCaixa(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.error != null) {
                        return Scaffold(
                          body: Center(
                            child: Text('Algo deu errado :('),
                          ),
                        );
                      } else {
                        print("abri a caixa Hive");
                        
                        return Scaffold(
                          body: Stack(

                            children: <Widget>[
                              BodyBackground(),
                      Center(
                        child: Column
                        (
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>
                          [
                  
                              SizedBox(height: 40, ),
                              Image.asset('assets/images/oca_viva-logo.png',height: 167,width: 154 ,),
                              SizedBox(height: 8, ),
                              Texto(conteudo: fraseInicial, tamFonte: 20),
                              InkWell
                              (
                                onTap: () {
                                  Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => RegistroPage() )
                                  );
                                },
                                child: Botao(conteudo: "Registre-se", tamFonte: 25)
                              ) ,   
                              Texto(conteudo: "\nSe já possui conta:\n", tamFonte: 20),
                              InkWell
                              (
                                onTap: () {
                                  Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => LoginPage() )
                                  );
                                },
                                child: Botao(conteudo: "Login", tamFonte: 25)
                              ) ,
                              
                            ],
                          ),
                        ),
                            ],
                          ),

                        );
                        
                              

                      }
                    } else {
                      return SimpleDialog(
                                  key: _keyLoader,
                                  backgroundColor: Colors.white,
                                  children: <Widget>[
                                    Center(
                                      child: Column(children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 10,),
                                        Text("Iniciando....",style: TextStyle(color: Colors.deepPurple),)
                                      ]),
                                    )
                                  ]
                      );
                    }
    
                                 
                  },
    );
  }

  Future checkFirstSeen() async 
  {
    Box<Usuario> boxUsers2 = Hive.box<Usuario>('users');
    prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);
    if (_seen)
    {
      if(userAuth.usuario == null){
      var indice =  0;
      var email = prefs.getString('email');
      var senha = prefs.getString('email');
      for (Usuario item in boxUsers2.values.toList()) {
        //showDialog(context: context, child: Center(child: CircularProgressIndicator()));
        if (item.email == email && item.senha == senha) {
          print("esse é o indice:"+indice.toString());
          userAuth.usuario = item;
          userAuth.indice = indice;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('email', item.email);
          prefs.setString('senha', item.senha);
           Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => new HomePage()));
        //abrirCaixa();    
        //userAuth.getFromFirestore();    
          log("Tela de Home Page");
            
          
          //showDialog(context: context, child: Center(child: CircularProgressIndicator()));
          //return Navigator.push(context, new MaterialPageRoute(builder: (context) => new HomePage())); 
        }
        indice++;


       }
     }
     else
       Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => new LoginPage()));
     
        
    }
    else
    {
        await prefs.setBool('seen', true);
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (context) => new WelcomePage()));
        log("Tela de welcome");
    }
  }
}