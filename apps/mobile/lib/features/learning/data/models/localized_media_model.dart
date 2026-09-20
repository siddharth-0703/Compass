import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/lesson.dart';

part 'localized_media_model.freezed.dart';
part 'localized_media_model.g.dart';

@freezed
class LocalizedMediaSourceModel with _$LocalizedMediaSourceModel {
  const factory LocalizedMediaSourceModel({
    required String contentUrl,
    required String provider,
    required String contentType,
  }) = _LocalizedMediaSourceModel;

  factory LocalizedMediaSourceModel.fromJson(Map<String, dynamic> json) =>
      _$LocalizedMediaSourceModelFromJson(json);
}

extension LocalizedMediaSourceModelX on LocalizedMediaSourceModel {
  LocalizedMediaSource toEntity() => LocalizedMediaSource(
        contentUrl: contentUrl,
        provider: provider,
        contentType: contentType,
      );
}

@freezed
class LocalizedMediaModel with _$LocalizedMediaModel {
  const factory LocalizedMediaModel({
    LocalizedMediaSourceModel? en,
    LocalizedMediaSourceModel? hi,
    LocalizedMediaSourceModel? mr,
  }) = _LocalizedMediaModel;

  factory LocalizedMediaModel.fromJson(Map<String, dynamic> json) =>
      _$LocalizedMediaModelFromJson(json);
}

extension LocalizedMediaModelX on LocalizedMediaModel {
  LocalizedMedia toEntity() => LocalizedMedia(
        en: en?.toEntity(),
        hi: hi?.toEntity(),
        mr: mr?.toEntity(),
      );
}
