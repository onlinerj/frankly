import 'dart:convert';
import 'package:data_models/community/community.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/templates/template.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/utils/calendar_link_util.dart';
import 'package:test/test.dart';

void main() {
  final community = Community(id: 'community', name: 'Calendar & Community');
  const template = Template(id: 'template', title: 'Template');
  final event = Event(
    id: 'event',
    status: EventStatus.active,
    communityId: community.id,
    templateId: template.id,
    collectionPath: 'community/community/templates/template/events',
    creatorId: 'organizer',
    title: 'Discussion & questions',
    scheduledTime: DateTime.utc(2026, 10, 1, 14),
    durationInMinutes: 60,
  );
  final util = CalendarLinkUtil();
  final eventUrl = 'https://${functions.config.get('app.domain')}'
      '/space/community/discuss/template/event';

  test('capture calendar evidence', () {
    print('CALENDAR_EVIDENCE:' + jsonEncode({
      'eventUrl': eventUrl,
      'google': util.getGoogleLink(community: community, template: template, event: event),
      'office365': util.getOffice365Link(community: community, template: template, event: event),
      'outlook': util.getOutlookLink(community: community, template: template, event: event),
      'ics': util.getICS(community: community, template: template, event: event),
    }));
  });
}
