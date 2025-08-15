import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../common/helpers/error_helper.dart';
import '../../../../common/models/failure.dart';
import '../../../../di.dart';
import '../../../../entities/solve_request/solve_request.dart';
import '../datasources/solving_remote_datasource.dart';

abstract class SolvingRepository {
  Future<Either<Failure, SolveRequest>> submitSolveImage({required File image, String? prompt});
}

class SolvingRepositoryImpl implements SolvingRepository {
  SolvingRepositoryImpl();

  final SolvingRemoteDatasource _remoteDatasource = getIt<SolvingRemoteDatasource>();

  @override
  Future<Either<Failure, SolveRequest>> submitSolveImage({required File image, String? prompt}) async {
    try {
      final mapped = await _remoteDatasource.submitSolve(image: image, prompt: prompt);
      return Right(mapped);
    } catch (e, s) {
      print("🐞Error: $e");
      print("🐞Stacktrace: $s");
      return Left(ErrorHelper.errorToFailure(e, stacktrace: s));
    }
  }
}
