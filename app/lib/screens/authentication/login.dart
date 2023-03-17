import 'package:flutter/material.dart';

import 'package:app/screens/authentication/signup.dart';
import 'package:app/components/form_button.dart';
import 'package:app/logic/fetch.dart';
import 'package:app/components/text_form_input.dart';
import 'package:app/logic/validate.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Bem-Vindo',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: TextFormInput(
                      label: 'Email',
                      controller: emailController,
                      validator: (value) => Validate.email(value),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: TextFormInput(
                        label: 'Senha',
                        controller: passwordController,
                        validator: (value) => Validate.password(value)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                    child: FormButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        Fetch(
                                context: context,
                                data: {
                                  'email': emailController.text,
                                  'password': passwordController.text
                                },
                                method: HttpMethods.mPost,
                                auth: true,
                                path: '/api/v1/login')
                            .exec();
                      },
                      body: const Text('Logar'),
                    ),
                  )
                ],
              )),
          Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUp()));
                },
                child: const Text('Criar Conta'),
              )),
        ],
      ),
    );
  }
}
