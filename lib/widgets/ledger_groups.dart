import 'package:flutter/material.dart';

import '../models/category.dart';
import 'common.dart';

/// Color for a signed money amount: green when they owe you (+), amber
/// when you owe them (−).
Color ledgerAmountColor(BuildContext context, Category c, int signedMinor) {
  if (signedMinor == 0) return context.ink3;
  return signedMinor > 0 ? context.success : context.warning;
}
