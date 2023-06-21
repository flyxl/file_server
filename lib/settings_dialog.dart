import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_server/settings.dart';

class SettingsDialog extends StatefulWidget {
  final Settings settings;
  const SettingsDialog(this.settings, {Key? key}) : super(key: key);
  @override
  SettingsDialogState createState() => SettingsDialogState();
}

class SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _portController;
  late TextEditingController _rootDirController;
  @override
  void initState() {
    super.initState();
    _portController =
        TextEditingController(text: widget.settings.port.toString());
    _rootDirController =
        TextEditingController(text: widget.settings.rootDirectory);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Port:'),
            TextField(
              controller: _portController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text('Root Directory:'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rootDirController,
                    enabled: false,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.getDirectoryPath();
                    if (result != null) {
                      setState(() {
                        // _rootDirController.text = result.path;
                        _rootDirController.text = result;
                      });
                    }
                  },
                  icon: const Icon(Icons.folder_open),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.settings.port = int.parse(_portController.text);
            widget.settings.rootDirectory = _rootDirController.text;
            widget.settings.save();
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _portController.dispose();
    _rootDirController.dispose();
    super.dispose();
  }
}
