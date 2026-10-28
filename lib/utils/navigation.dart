import 'package:flutter/material.dart';

import '../models/visitor.dart';
import '../screens/visitor_details_screen.dart';
import '../screens/visitor_form_screen.dart';

Future<void> openVisitorForm(BuildContext context, {Visitor? visitor}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => VisitorFormScreen(visitor: visitor),
    ),
  );
}

Future<void> openVisitorDetails(BuildContext context, String visitorId) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext context) =>
          VisitorDetailsScreen(visitorId: visitorId),
    ),
  );
}
