import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';

/// ISO 5218 sex.
enum Sex { notKnown, male, female, notApplicable }

@freezed
class TargetState with _$TargetState {
  factory TargetState.partial({
    String? id,
    String? name,
    Sex? sex,
    int? age,
    String? note,
  }) = TargetStatePartial;

  factory TargetState.completed({
    required String id,
    required String name,
    required Sex sex,
    required int age,
    required String note,
  }) = TargetStateCompleted;
}

// TODO: validators, dummy async submits
