import 'package:xpm/utils/out.dart';

void main() {
  final message = 'Hello, World!';
  out('fuck {message}', error: true, replace: {'message': message});
}
