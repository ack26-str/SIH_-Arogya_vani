import 'package:flutter_riverpod/legacy.dart';
import '../../../../models/clinical_summary.dart';

final activeSummaryProvider = StateProvider<ClinicalSummary?>((ref) => null);

final summaryConfirmedProvider = StateProvider<bool>((ref) => false);
final summarySharedProvider = StateProvider<bool>((ref) => false);
