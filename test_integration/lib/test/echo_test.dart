import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:test_integration/config/data.dart';

import '../test_dispatcher.dart';
import 'utils.dart';

Future<Map<String, dynamic>> echoTest(
    {TestDispatcherState dispatcher, Map<String, dynamic> payload}) async {
  payload ??= {
    'options': {'url': 'http://192.168.0.107:7000/'}
  };
  final manager = SocketIOManager();
  final socket = await manager.createInstance(getSocketOptions(payload));
  final messages = <Object>[];
  // connect
  await socket.connect();

  final subscription =
      socket.on('echo').listen(messages.add);

  for (final message in messagesToPublish) {
    await socket.emit('echo', [message]);
  }

  await socket.emit('echo', messagesToPublish.last as List);

  // waiting and disconnecting
  await Future.delayed(const Duration(seconds: 2));
  await manager.clearInstance(socket);

  // attributing to the async delays from stream channel
  // waiting to receive events, and then cancelling subscriptions
  await Future.delayed(const Duration(seconds: 2));
  await subscription.cancel();

  return {'id': socket.id, 'messages': messages};
}
