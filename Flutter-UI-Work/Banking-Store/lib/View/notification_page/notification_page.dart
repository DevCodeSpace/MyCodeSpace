import 'package:banking_store/Export/export.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';
import 'package:flutter/cupertino.dart' as cupertino;

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            70.hBox,
            // Menu icons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: StoreColors.darkGreen.withValues(alpha: 0.9),
                    size: 30,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: StoreColors.darkGreen.withValues(alpha: 0.9),
                      size: 30,
                    ),
                    15.wBox,
                    Icon(
                      cupertino.CupertinoIcons.add_circled_solid,
                      color: StoreColors.darkGreen.withValues(alpha: 0.9),
                      size: 30,
                    ),
                  ],
                ),
              ],
            ).pH(30),
            35.hBox,
            Text(
              'Notifications',
              softWrap: true,
              maxLines: 2,
              style: boldTextStyle(color: StoreColors.darkTeal, 23),
            ).pH(30),
            15.hBox,
            Container(
              decoration: BoxDecoration(
                color: StoreColors.lightGrey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You\'ve spent \$10,100 on stuff which you even didn\'t needed!! ( just kidding!! )',
                          softWrap: true,
                          maxLines: 2,
                          style: mediumTextStyle(
                            color: StoreColors.darkTeal.withValues(alpha: 0.6),
                            14,
                          ),
                        ),
                        10.hBox,
                        Row(
                          children: [
                            Icon(
                              Icons.bar_chart_rounded,
                              color: StoreColors.darkGreen,
                              size: 18,
                            ),
                            8.wBox,
                            Text(
                              '10% of spending',
                              softWrap: true,
                              maxLines: 2,
                              style: boldTextStyle(
                                color: StoreColors.darkGreen,
                                15,
                              ),
                            ),
                            3.wBox,
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: StoreColors.darkGreen,
                              size: 15,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  7.wBox,
                  Container(
                    height: 28,
                    width: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: StoreColors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '8',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ).pH(18).pV(24),
            ).pH(30),
            30.hBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      'Budget',
                      style: boldTextStyle(color: Colors.grey, 18),
                    ),
                    Text(
                      '\$11,020',
                      style: boldTextStyle(color: StoreColors.darkGreen, 30),
                    ),
                  ],
                ),
                // Make a thing vertical line
                Container(
                  height: 110,
                  width: 0.7,
                  color: Colors.grey.withValues(alpha: 0.5),
                ),
                Column(
                  children: [
                    Text('Bills', style: boldTextStyle(color: Colors.grey, 18)),
                    Text(
                      '\$8,020',
                      style: boldTextStyle(color: StoreColors.darkGreen, 30),
                    ),
                  ],
                ),
              ],
            ),
            20.hBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spendings',
                  style: TextStyle(
                    color: StoreColors.darkTeal,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ).pH(30),
            15.hBox,
            SizedBox(
              height: 185,
              child: ListView.builder(
                itemCount: SpendingModel.dummy().length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final model = SpendingModel.dummy()[index];
                  return Container(
                    width: 135,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: model.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(),
                    child: Column(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                model.assetName,
                                width: 45,
                                color: model.iconColor,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                model.name,
                                style: TextStyle(
                                  color: model.iconColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                model.price,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: model.iconColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '/mo',
                                style: TextStyle(
                                  color: model.iconColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).pSymmetric(h: 16, v: 20),
                  ).pOnly(l: index == 0 ? 30 : 0);
                },
              ),
            ),
            20.hBox,
            Text(
              'Budget',
              softWrap: true,
              maxLines: 2,
              style: TextStyle(
                color: StoreColors.darkTeal,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ).pH(30),
            15.hBox,
            Container(
              decoration: BoxDecoration(
                color: StoreColors.lightGrey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    height: 57,
                    width: 57,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: StoreColors.darkGreen,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      Icons.thumb_up_alt_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You\'ve saved \$100 that now you can atleast dream to buy a used Tesla.',
                          style: TextStyle(
                            color: StoreColors.darkTeal.withValues(alpha: 0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'View budget',
                              softWrap: true,
                              maxLines: 2,
                              style: TextStyle(
                                color: StoreColors.darkGreen,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: StoreColors.darkGreen,
                              size: 15,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ).pSymmetric(h: 18, v: 22),
            ).pH(30),
          ],
        ),
      ),
    );
  }
}
