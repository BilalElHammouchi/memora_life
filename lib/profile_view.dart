// ignore_for_file: use_build_context_synchronously
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:memora_life/firebase_wrapper.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  String _password = '********';
  String _email = 'johndoe@example.com';
  bool _isUsernameEditable = false;
  bool _isPasswordEditable = false;
  int _isLoading = -1;

  @override
  void initState() {
    super.initState();
    _usernameController.text = FirebaseWrapper.username;
    _passwordController.text = _password;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void toggleEditPassword() {
    setState(() {
      _isPasswordEditable = !_isPasswordEditable;
    });
  }

  Future<void> toggleEditUsername() async {
    if (_isUsernameEditable) {
      setState(() {
        _isLoading = 0;
      });
      bool usernameUnique =
          await FirebaseWrapper.usernameUnique(_usernameController.text);
      bool AllowUsernameEdit = usernameUnique ||
          _usernameController.text == FirebaseWrapper.username;
      setState(() {
        _isLoading = -1;
      });
      if (AllowUsernameEdit) {
        FirebaseWrapper.updateUsername(_usernameController.text);
        setState(() {
          _isUsernameEditable = !_isUsernameEditable;
        });
      } else {
        ElegantNotification.error(
            width: 100,
            title: const Text(
              "Username Duplicate",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            description: const Text(
              "This username has already been picked. Try another one",
              style: TextStyle(color: Colors.black),
            )).show(context);
      }
    } else {
      setState(() {
        _isUsernameEditable = !_isUsernameEditable;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: FirebaseWrapper.profilePicture.image,
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    Image? placeholderImage = await FirebaseWrapper.uploadPic();
                    if (placeholderImage != null) {
                      setState(() {
                        FirebaseWrapper.profilePicture = placeholderImage;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextFieldWithLabel(
                    'Username',
                    Icons.person,
                    _usernameController,
                    _isUsernameEditable,
                    toggleEditUsername,
                    0),
                const SizedBox(height: 16),
                _buildTextFieldWithLabel(
                    'Password',
                    Icons.lock,
                    _passwordController,
                    _isPasswordEditable,
                    toggleEditPassword,
                    1),
                const SizedBox(height: 16),
                _buildTextFieldWithLabel(
                    'Email', Icons.email, null, false, null, 2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyTextFieldWithLabel(
      String label, IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(icon),
          ),
          Expanded(
            child: TextFormField(
              initialValue: text,
              readOnly: true,
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithLabel(
    String label,
    IconData icon,
    TextEditingController? controller,
    bool isEditable,
    VoidCallback? onToggleEdit,
    int ord,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(icon),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: !isEditable,
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
              ),
            ),
          ),
          if (_isLoading == ord)
            const CircularProgressIndicator()
          else if (!isEditable)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onToggleEdit,
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: onToggleEdit,
            )
        ],
      ),
    );
  }
}
