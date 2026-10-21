import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';
import 'package:shopsphere/features/auth/domain/entities/user_entity.dart';
import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tUserModel = UserModel(
    id: 1,
    username: 'emilys',
    email: 'emily.johnson@x.dummyjson.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    gender: 'female',
    image: 'https://dummyjson.com/icon/emilys/128',
    phone: '+81 965-431-3024',
  );

  test('should be a subclass of UserEntity', () {
    expect(tUserModel, isA<UserEntity>());
  });

  group('fromJson', () {
    test('should parse user fixture JSON correctly', () {
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('user_fixture.json')) as Map<String, dynamic>;

      final result = UserModel.fromJson(jsonMap);

      expect(result.id, 1);
      expect(result.username, 'emilys');
      expect(result.fullName, 'Emily Johnson');
      expect(result.phone, '+81 965-431-3024');
    });
  });

  group('toJson', () {
    test('should return a JSON map containing correct user properties', () {
      final result = tUserModel.toJson();

      final expectedMap = {
        'id': 1,
        'username': 'emilys',
        'email': 'emily.johnson@x.dummyjson.com',
        'firstName': 'Emily',
        'lastName': 'Johnson',
        'gender': 'female',
        'image': 'https://dummyjson.com/icon/emilys/128',
        'phone': '+81 965-431-3024',
      };

      expect(result, expectedMap);
    });
  });
}
