import 'package:dcm_flutter/resources/strings.dart';
import 'package:dcm_flutter/view/widgets/drop_down.dart';
import 'package:dcm_flutter/viewmodel/login_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main_page.dart';

// Starting Page selected by DCMApp class inside main.dart
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _viewModel = LoginViewModel();

  final _companySelectController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  var _companies = [];
  bool _isLoading = false;
  bool _pwVisible = false;

  // hide or unhide progress indicator
  void _toggleLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  /*
  Gets called, when login button gets clicked.
  Calls login function from LoginPageViewModel.
    If successful, the Login Page gets replaced by the MainPage.dart
    If login failed an error message is shown
   */
  void _login() {
    _toggleLoading(true);
    _viewModel.login(_companySelectController.text, _usernameController.text, _passwordController.text).then((user) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
        return MainPage(user);
      }));
    }).onError((error, stackTrace) {
      const snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text("Benutzername oder Kennwort ist falsch."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }).whenComplete(() => _toggleLoading(false));
  }

  // Requests Company Data for DropDown list and listens for results from LoginPageViewModel
  @override
  void initState() {
    super.initState();

    _viewModel.getCompanyData();
    _viewModel.companies.stream.listen((companies) {
      setState(() {
        _usernameController.text = "e@mail.de";
        _passwordController.text = "1234abcd";
        _companies = companies;
      });
    });
  }


  // Login Page UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.appName + " Login"),
        actions: [
          IconButton(
              onPressed: () => showAboutDialog(context: context, children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    const url = 'https://cif24.de/login?customer=47110815';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  icon: const Icon(Icons.web_asset, size: 18),
                  label: const Text(Strings.menuWeb),
                ),
              ]),
              icon: const Icon(Icons.more_vert))
        ],
      ),
      body: Column(children: [
        Visibility(
          child: const LinearProgressIndicator(),
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible: _isLoading,
        ),
        Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(Strings.txtCompany, style: textTheme.headline2),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Hotel in Focus", style: textTheme.headline3),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Kundennr.: 47110815", style: textTheme.headline3),
                ),
                const SizedBox(height: 24),
                DropDownInputField(
                  showInitValue: false,
                  controller: _companySelectController,
                  hint: Strings.hintCompany,
                  onChanged: () => setState(() {
                    _companySelectController.text;
                  }),
                  options: _companies,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                    labelText: Strings.hintUsername,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    hintText: Strings.hintUsername,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  keyboardType: TextInputType.text,
                  obscureText: !_pwVisible,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: Strings.hintPw,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    hintText: Strings.hintPw,
                    prefixIcon: const Icon(Icons.vpn_key),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _pwVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _pwVisible = !_pwVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  child: ElevatedButton(
                    onPressed: _login,
                    child: const Text(Strings.btnLogin, style: TextStyle(fontSize: 18)),
                  ),
                  alignment: Alignment.centerRight,
                )
              ],
            ))
      ]),
    );
  }
}
