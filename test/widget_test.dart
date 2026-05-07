import 'package:expense_tracker/core/enums.dart';
import 'package:expense_tracker/core/formatters.dart';
import 'package:expense_tracker/presentation_layer/add/widgets/transaction_form_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats signed transaction amounts by tone', () {
    expect(
      AppFormatters.signedAmount(amount: 1250, tone: TransactionTone.income),
      '+\$1,250',
    );
    expect(
      AppFormatters.signedAmount(amount: 1250, tone: TransactionTone.expense),
      '-\$1,250',
    );
  });

  test('decimal amount input accepts one decimal point only', () {
    final formatter = DecimalAmountInputFormatter();
    const oldValue = TextEditingValue(text: '12.5');

    final acceptedValue = formatter.formatEditUpdate(
      oldValue,
      const TextEditingValue(text: '12.50'),
    );
    expect(acceptedValue.text, '12.50');

    final rejectedValue = formatter.formatEditUpdate(
      oldValue,
      const TextEditingValue(text: '12.5.0'),
    );
    expect(rejectedValue.text, oldValue.text);
  });
}
