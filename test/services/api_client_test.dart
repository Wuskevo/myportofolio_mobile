import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/credential.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

void main() {
  const baseUrl = 'https://api.example.test';

  group('getExperiences', () {
    test('requests the public list and parses its response', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), '$baseUrl/api/v1/experiences/');
        expect(request.headers['accept'], 'application/json');

        return http.Response(
          jsonEncode([
            {
              'id': 'experience-1',
              'title': 'Intern',
              'description': 'Built mobile features',
              'category': 'internship',
              'started_at': '2024-01-02',
              'ended_at': null,
            },
          ]),
          200,
        );
      });
      addTearDown(mockClient.close);
      final apiClient = ApiClient(client: mockClient, baseUrl: baseUrl);

      final experiences = await apiClient.getExperiences();

      expect(experiences, hasLength(1));
      expect(experiences.single.id, 'experience-1');
      expect(experiences.single.title, 'Intern');
      expect(experiences.single.startedAt, DateTime(2024, 1, 2));
      expect(experiences.single.endedAt, isNull);
      expect(experiences.single.thumbnail, '');
    });

    test('surfaces unauthorized responses as ApiException', () async {
      final mockClient = MockClient(
        (_) async => http.Response('Invalid token', 401),
      );
      addTearDown(mockClient.close);
      final apiClient = ApiClient(client: mockClient, baseUrl: baseUrl);

      await expectLater(
        apiClient.getExperiences(),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 401)
              .having((error) => error.message, 'message', 'Invalid token'),
        ),
      );
    });
  });

  group('getCredentials', () {
    test('requests the public list and parses its response', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), '$baseUrl/api/v1/credentials/');
        expect(request.headers['accept'], 'application/json');

        return http.Response(
          jsonEncode([
            {
              'id': 'credential-1',
              'title': 'Flutter Certificate',
              'description': 'Completed a course',
              'category': 'certification',
              'issuer': 'Example Academy',
              'date_received': '2024-02-03',
              'expiry_date': null,
            },
          ]),
          200,
        );
      });
      addTearDown(mockClient.close);
      final apiClient = ApiClient(client: mockClient, baseUrl: baseUrl);

      final credentials = await apiClient.getCredentials();

      expect(credentials, hasLength(1));
      expect(credentials.single.id, 'credential-1');
      expect(credentials.single.title, 'Flutter Certificate');
      expect(credentials.single.dateReceived, DateTime(2024, 2, 3));
      expect(credentials.single.expiryDate, isNull);
      expect(credentials.single.credentialUrl, '');
    });
  });

  group('createExperience', () {
    test(
      'sends an authenticated JSON request and parses the response',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.toString(), '$baseUrl/api/v1/experiences/');
          expect(request.headers['accept'], 'application/json');
          expect(
            request.headers['content-type'],
            'application/json; charset=UTF-8',
          );
          expect(request.headers['authorization'], 'Token test-token');
          expect(jsonDecode(request.body), {
            'title': 'Intern',
            'description': 'Built mobile features',
            'category': 'internship',
            'thumbnail': 'https://example.test/image.png',
            'started_at': '2024-01-02T00:00:00.000Z',
            'ended_at': null,
          });

          return http.Response(
            jsonEncode({
              'id': 'experience-created',
              'title': 'Intern',
              'description': 'Built mobile features',
              'category': 'internship',
              'thumbnail': 'https://example.test/image.png',
              'started_at': '2024-01-02',
              'ended_at': null,
            }),
            201,
          );
        });
        addTearDown(mockClient.close);
        final apiClient = ApiClient(client: mockClient, baseUrl: baseUrl);
        final experience = Experience(
          id: 'must-not-be-sent',
          title: 'Intern',
          description: 'Built mobile features',
          category: 'internship',
          thumbnail: 'https://example.test/image.png',
          startedAt: _utcDate(2024, 1, 2),
        );

        final created = await apiClient.createExperience(
          experience,
          token: 'test-token',
        );

        expect(created.id, 'experience-created');
        expect(created.title, 'Intern');
      },
    );
  });

  group('createCredential', () {
    test('sends authenticated JSON with date-only fields', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), '$baseUrl/api/v1/credentials/');
        expect(request.headers['authorization'], 'Token test-token');
        expect(jsonDecode(request.body), {
          'title': 'Flutter Certificate',
          'description': 'Completed a course',
          'category': 'certification',
          'issuer': 'Example Academy',
          'date_received': '2024-02-03',
          'expiry_date': '2026-02-03',
          'credential_url': 'https://example.test/verify',
        });

        return http.Response(
          jsonEncode({
            'id': 'credential-created',
            'title': 'Flutter Certificate',
            'description': 'Completed a course',
            'category': 'certification',
            'issuer': 'Example Academy',
            'date_received': '2024-02-03',
            'expiry_date': '2026-02-03',
            'credential_url': 'https://example.test/verify',
          }),
          201,
        );
      });
      addTearDown(mockClient.close);
      final apiClient = ApiClient(client: mockClient, baseUrl: baseUrl);
      final credential = Credential(
        id: 'must-not-be-sent',
        title: 'Flutter Certificate',
        description: 'Completed a course',
        category: 'certification',
        issuer: 'Example Academy',
        dateReceived: _utcDate(2024, 2, 3),
        expiryDate: _utcDate(2026, 2, 3),
        credentialUrl: 'https://example.test/verify',
        image: 'not-uploaded.png',
      );

      final created = await apiClient.createCredential(
        credential,
        token: 'test-token',
      );

      expect(created.id, 'credential-created');
      expect(created.title, 'Flutter Certificate');
    });
  });

  group('delete requests', () {
    test(
      'deletes projects with the item ID and auth token',
      () => _expectDeleteRequest(
        path: '/api/v1/projects/project-1/',
        delete: (apiClient) =>
            apiClient.deleteProject('project-1', token: 'test-token'),
      ),
    );

    test(
      'deletes experiences with the item ID and auth token',
      () => _expectDeleteRequest(
        path: '/api/v1/experiences/experience-1/',
        delete: (apiClient) =>
            apiClient.deleteExperience('experience-1', token: 'test-token'),
      ),
    );

    test(
      'deletes credentials with the item ID and auth token',
      () => _expectDeleteRequest(
        path: '/api/v1/credentials/credential-1/',
        delete: (apiClient) =>
            apiClient.deleteCredential('credential-1', token: 'test-token'),
      ),
    );

    test('surfaces a forbidden response as ApiException', () async {
      final mockClient = MockClient(
        (_) async => http.Response('Permission denied', 403),
      );
      addTearDown(mockClient.close);
      final apiClient = ApiClient(client: mockClient, baseUrl: baseUrl);

      await expectLater(
        apiClient.deleteProject('project-1', token: 'test-token'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 403)
              .having((error) => error.message, 'message', 'Permission denied'),
        ),
      );
    });
  });
}

Future<void> _expectDeleteRequest({
  required String path,
  required Future<void> Function(ApiClient apiClient) delete,
}) async {
  const baseUrl = 'https://api.example.test';
  final mockClient = MockClient((request) async {
    expect(request.method, 'DELETE');
    expect(request.url.toString(), '$baseUrl$path');
    expect(request.headers['accept'], 'application/json');
    expect(request.headers['authorization'], 'Token test-token');
    return http.Response('', 204);
  });
  addTearDown(mockClient.close);
  final apiClient = ApiClient(client: mockClient, baseUrl: baseUrl);

  await delete(apiClient);
}

DateTime _utcDate(int year, int month, int day) =>
    DateTime.utc(year, month, day);
