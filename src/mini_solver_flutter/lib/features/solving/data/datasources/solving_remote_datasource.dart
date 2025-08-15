
import 'dart:io';

import '../../../../di.dart';
import '../../../../entities/solve_request/solve_request.dart';
import '../../../../modules/rest_module/restful_module.dart';

abstract class SolvingRemoteDatasource {
  Future<SolveRequest> submitSolve({required File image, String? prompt});
}

class SolvingRemoteDatasourceImpl implements SolvingRemoteDatasource {
  final RestfulModule _rest = getIt();

  @override
  Future<SolveRequest> submitSolve({required File image, String? prompt}) async {
    final form = <String, dynamic>{
      'image': image,
      if (prompt != null && prompt.isNotEmpty) 'prompt': prompt,
    };
    final response = await _rest.postMultipart<Map<String, dynamic>>('/solve', form);
    return SolveRequest.fromJson(response.data as Map<String, dynamic>);
  }
}

