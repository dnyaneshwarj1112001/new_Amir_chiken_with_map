import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'counter_cubit_state.dart';

class CounterCubitCubit extends Cubit<int> {
  CounterCubitCubit() : super(1);
  void incerment()=>emit(state+1);
  void decerment()=>emit(state-1);
}
