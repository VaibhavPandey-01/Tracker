import 'package:equatable/equatable.dart';

/// Represents the user's current financial partition state.
/// This is a single active document per user in Firestore.
class FundState extends Equatable {
  const FundState({
    required this.principalAmount,
    required this.lockedAmount,
    required this.lastUpdated,
  });

  final double principalAmount;
  final double lockedAmount;
  final DateTime lastUpdated;

  /// Derived — never stored separately to avoid drift.
  /// spendableAmount = principalAmount - lockedAmount
  double get spendableAmount => principalAmount - lockedAmount;

  /// True when spendable has gone negative (overspent)
  bool get isOverspent => spendableAmount < 0;

  FundState copyWith({
    double? principalAmount,
    double? lockedAmount,
    DateTime? lastUpdated,
  }) {
    return FundState(
      principalAmount: principalAmount ?? this.principalAmount,
      lockedAmount: lockedAmount ?? this.lockedAmount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'principalAmount': principalAmount,
      'lockedAmount': lockedAmount,
      // Store derived value for fast reads (web app convenience)
      'spendableAmount': spendableAmount,
      'lastUpdated': lastUpdated.toUtc().toIso8601String(),
    };
  }

  factory FundState.fromFirestore(Map<String, dynamic> data) {
    return FundState(
      principalAmount: (data['principalAmount'] as num).toDouble(),
      lockedAmount: (data['lockedAmount'] as num).toDouble(),
      lastUpdated: DateTime.parse(data['lastUpdated'] as String).toLocal(),
    );
  }

  /// Default empty state used before onboarding completes
  static FundState get empty => FundState(
        principalAmount: 0,
        lockedAmount: 0,
        lastUpdated: DateTime.now(),
      );

  @override
  List<Object?> get props => [principalAmount, lockedAmount, lastUpdated];
}
