import 'package:json_annotation/json_annotation.dart';
part 'credential.g.dart';

String _dateToJson(DateTime date) => date.toIso8601String().split('T').first;

String? _nullableDateToJson(DateTime? date) =>
    date?.toIso8601String().split('T').first;

@JsonSerializable(fieldRename: FieldRename.snake)
class Credential {
  const Credential({
    
    required this.title,
    required this.description,
    required this.category,
    required this.issuer,
    required this.dateReceived,
    this.expiryDate,
    this.credentialUrl = '',
    this.image,
    this.id,
  });

  factory Credential.fromJson(Map<String, dynamic> json) =>
      _$CredentialFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String description;
  final String category;
  final String issuer;
  @JsonKey(toJson: _dateToJson)
  final DateTime dateReceived;
  @JsonKey(toJson: _nullableDateToJson)
  final DateTime? expiryDate;
  @JsonKey(defaultValue: '')
  final String credentialUrl;
  @JsonKey(includeToJson: false)
  final String? image;

  Map<String, dynamic> toJson() => _$CredentialToJson(this);
}
