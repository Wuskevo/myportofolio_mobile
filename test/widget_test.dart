import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/project.dart';

void main() {
  test('Project.fromJson maps snake_case keys', () {
    final project = Project.fromJson({
      'id': 'abc',
      'title': 'T',
      'description': 'D',
      'tech_stack': 'Django',
      'project_url': 'https://example.com',
    });

    expect(project.techStack, 'Django');
    expect(project.projectUrl, 'https://example.com');
    expect(project.projectImageUrl, '');
  });

  test('Project.toJson omits id and uses snake_case', () {
    const project = Project(
      id: 'abc',
      title: 'T',
      description: 'D',
      techStack: 'Django',
      projectUrl: 'https://example.com',
    );

    final json = project.toJson();
    expect(json.containsKey('id'), false);
    expect(json['tech_stack'], 'Django');
  });
}
