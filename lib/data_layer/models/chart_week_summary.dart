class ChartWeekSummary {
  const ChartWeekSummary({
    required this.label,
    required this.incomeAmount,
    required this.expenseAmount,
    required this.incomeRatio,
    required this.expenseRatio,
  });

  final String label;
  final double incomeAmount;
  final double expenseAmount;
  final double incomeRatio;
  final double expenseRatio;
}
