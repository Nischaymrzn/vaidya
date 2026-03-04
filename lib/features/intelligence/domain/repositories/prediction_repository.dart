import 'package:dartz/dartz.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/intelligence/domain/entities/prediction_entity.dart';

abstract interface class IPredictionRepository {
  Future<Either<Failure, PredictionEntity>> predictSymptom(List<String> symptoms);
  Future<Either<Failure, PredictionEntity>> predictHeartDisease(Map<String, dynamic> payload);
  Future<Either<Failure, PredictionEntity>> predictDiabetes(Map<String, dynamic> payload);
  Future<Either<Failure, PredictionEntity>> predictBrainTumor(String imagePath);
  Future<Either<Failure, PredictionEntity>> predictTuberculosis(String imagePath);
}
