import 'package:app/components/form_button.dart';
import 'package:app/components/text_form_input.dart';
import 'package:app/logic/fetch.dart';
import 'package:app/logic/validate.dart';
import 'package:flutter/material.dart';

class SignUp extends StatelessWidget {
  SignUp({super.key});

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Criar Conta')),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: TextFormInput(
                        label: 'Email',
                        controller: emailController,
                        validator: (value) => Validate.email(value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: TextFormInput(
                          label: 'Username',
                          controller: usernameController,
                          validator: (value) => Validate.username(value)),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: TextFormInput(
                                label: 'Senha',
                                controller: passwordController,
                                validator: (value) => Validate.password(value),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                                child: TextFormInput(
                                    label: 'Confirmar Senha',
                                    controller: passwordConfirmController,
                                    validator: (value) =>
                                        Validate.correctPassword(
                                            value, passwordController.text))),
                          ],
                        )),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                        child: FormButton(
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }
                              Fetch(
                                      context: context,
                                      data: {
                                        'email': emailController.text,
                                        'username': usernameController.text,
                                        'password':
                                            passwordConfirmController.text
                                      },
                                      method: HttpMethods.mPost,
                                      auth: true,
                                      path: '/api/v1/signup')
                                  .exec();
                            },
                            body: const Text('Criar')))
                  ],
                )),
          ],
        ));
  }
}
