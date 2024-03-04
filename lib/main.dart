import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:flutter/material.dart';

final user32 = ffi.DynamicLibrary.open('user32.dll');

class WindowsFunctions {
  static const EWX_SHUTDOWN = 0x00000001;
  static const EWX_REBOOT = 0x00000002;

  static int ExitWindowsEx(int uFlags, int dwReason) {
    final exitWindowsEx = user32.lookupFunction<
        ffi.Int32 Function(ffi.Uint32, ffi.Uint32),
        int Function(int, int)>('ExitWindowsEx');
    return exitWindowsEx(uFlags, dwReason);
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('System Control App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Execute shutdown command
                  Process.run('shutdown', ['/s']);
                },
                child: Text('Shutdown'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Execute restart command
                  Process.run('shutdown', ['/r']);
                },
                child: Text('Restart'),
              ),
              ElevatedButton(
                onPressed: () {
                  _showTimedShutdownDialog(context);
                },
                child: Text('Timed Shutdown'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to show a dialog for timed shutdown
  Future<void> _showTimedShutdownDialog(BuildContext context) async {
    int timeDelay = 0;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Timed Shutdown'),
          content: Column(
            children: [
              Text('Enter the time delay (in seconds):'),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  timeDelay = int.tryParse(value) ?? 0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performTimedShutdown(timeDelay);
              },
              child: Text('Shutdown'),
            ),
          ],
        );
      },
    );
  }

  // Function to perform timed shutdown
  void _performTimedShutdown(int timeDelay) {
    Timer(Duration(seconds: timeDelay), () {
      // Execute shutdown command after the specified time delay
      Process.run('shutdown', ['/s']);
    });
  }
}
