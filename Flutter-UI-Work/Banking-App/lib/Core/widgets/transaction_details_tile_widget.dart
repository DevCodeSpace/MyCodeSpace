import 'package:banking_app/Core/Theme/text_style.dart';
import 'package:banking_app/Export/export.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';

class TransactionDetailsTile extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailsTile({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      width: double.infinity,
      child: Row(
        children: [
          Container(
            height: 62,
            width: 60,
            decoration: BoxDecoration(
              color: BankingColors.veryLightGreen,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              transaction.category.icon,
              size: 26,
              color: BankingColors.darkGreen,
            ),
          ),
          15.wBox,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.payee,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: semiBoldTextStyle(18),
                ),
                5.hBox,
                Text(
                  transaction.date.toString().split('.')[0],
                  style: regularTextStyle(10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          20.wBox,
          Column(
            children: [
              9.hBox,
              Text(
                '${transaction.isIncome ? '+' : '-'} \$${transaction.amount}',
                style: boldTextStyle(
                  19,
                  color:
                      transaction.isIncome
                          ? BankingColors.darkGreen
                          : BankingColors.darkRed,
                ),
              ),
            ],
          ),
        ],
      ),
    ).pV(8);
  }
}
