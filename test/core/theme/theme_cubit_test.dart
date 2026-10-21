import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/theme/theme_cubit.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
  });

  test('should load ThemeMode.system by default when no preference is saved', () {
    when(() => mockSharedPreferences.getString('app_theme_mode')).thenReturn(null);

    final cubit = ThemeCubit(sharedPreferences: mockSharedPreferences);

    expect(cubit.state, ThemeMode.system);
    cubit.close();
  });

  test('should load ThemeMode.dark when saved preference is "dark"', () {
    when(() => mockSharedPreferences.getString('app_theme_mode'))
        .thenReturn('dark');

    final cubit = ThemeCubit(sharedPreferences: mockSharedPreferences);

    expect(cubit.state, ThemeMode.dark);
    cubit.close();
  });

  blocTest<ThemeCubit, ThemeMode>(
    'setThemeMode updates state and persists mode string to SharedPreferences',
    build: () {
      when(() => mockSharedPreferences.getString('app_theme_mode'))
          .thenReturn('light');
      when(() => mockSharedPreferences.setString('app_theme_mode', 'dark'))
          .thenAnswer((_) async => true);
      return ThemeCubit(sharedPreferences: mockSharedPreferences);
    },
    act: (cubit) => cubit.setThemeMode(ThemeMode.dark),
    expect: () => [ThemeMode.dark],
    verify: (_) {
      verify(() => mockSharedPreferences.setString('app_theme_mode', 'dark'))
          .called(1);
    },
  );

  blocTest<ThemeCubit, ThemeMode>(
    'toggleTheme switches from light to dark',
    build: () {
      when(() => mockSharedPreferences.getString('app_theme_mode'))
          .thenReturn('light');
      when(() => mockSharedPreferences.setString('app_theme_mode', 'dark'))
          .thenAnswer((_) async => true);
      return ThemeCubit(sharedPreferences: mockSharedPreferences);
    },
    act: (cubit) => cubit.toggleTheme(),
    expect: () => [ThemeMode.dark],
  );
}
