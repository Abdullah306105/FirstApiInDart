import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:supabase/supabase.dart';

// For Google Cloud Run, set _hostname to '0.0.0.0'.
const _hostname = 'localhost';

void main(List<String> args) async {
  var parser = ArgParser()..addOption('port', abbr: 'p');
  var result = parser.parse(args);

  // For Google Cloud Run, we respect the PORT environment variable
  var portStr = result['port'] ?? Platform.environment['PORT'] ?? '8080';
  var port = int.tryParse(portStr);

  if (port == null) {
    stdout.writeln('Could not parse port value "$portStr" into a number.');
    // 64: command line usage error
    exitCode = 64;
    return;
  }

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(_echoRequest);

  var server = await io.serve(handler, _hostname, port);
  print('Serving at http://${server.address.host}:${server.port}');
}

Future<shelf.Response> _echoRequest(shelf.Request request) async {
  switch (request.url.toString()) {
    case 'users':
      return _echoUsers(request);
    default:
      return shelf.Response.ok('Invalid url');
  }
}

Future<shelf.Response> _echoUsers(shelf.Request request) async {
  final client = SupabaseClient('https://oastmaofeeidyugbljxc.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9hc3RtYW9mZWVpZHl1Z2JsanhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTk0NzQwMDEsImV4cCI6MjAzNTA1MDAwMX0.id0OwyL6KZLmS_JENaXtn27CpcgV9gxdjeIJXLrM93U');

  // Retrieve data from 'users' table
  final response = await client.from('users').select();

  var map = {'users': response};


  

  return shelf.Response.ok(jsonEncode(map));

}
