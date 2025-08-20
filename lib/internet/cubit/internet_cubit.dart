// import 'package:meatzo/internet/cubit/internet_state.dart';
// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';



// class InternetCubit extends Cubit<InternetStatus> {
//   late final InternetConnectionChecker _connectionChecker;

//   InternetCubit() : super(const InternetStatus(ConnectivityStatus.connected)) {
//     _connectionChecker = InternetConnectionChecker();
//     _connectionChecker.onStatusChange.listen((status) {
//       emit(
//         status == InternetConnectionStatus.connected
//             ? const InternetStatus(ConnectivityStatus.connected)
//             : const InternetStatus(ConnectivityStatus.disconnected),
//       );
//     });
//   }
// }
