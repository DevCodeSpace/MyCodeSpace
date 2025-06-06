import 'package:banking_app/Core/Theme/text_style.dart';
import 'package:banking_app/Export/export.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';

class YourCardsWidget extends StatelessWidget {
  const YourCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 210,
        width: MediaQuery.of(context).size.width / 2 - 35,
        decoration: BoxDecoration(color: BankingColors.darkRed),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Your Cards',
                          style: boldTextStyle(13, color: Colors.white),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ).pOnly(l: 17, r: 15),
                    6.hBox,
                    SizedBox(
                      height: 135,
                      child: ListView.builder(
                        itemCount: 4,

                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 135,
                            width: 90,

                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color:
                                  index.isOdd
                                      ? Colors.black
                                      : BankingColors.yellow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '* * * *  1234',
                                  style: boldTextStyle(7, color: Colors.white),
                                ),
                                25.hBox,
                                Text(
                                  '2500 USD',
                                  textAlign: TextAlign.center,
                                  style: boldTextStyle(9, color: Colors.white),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset(
                                      'assets/mastercard.png',
                                      height: 15,
                                      width: 15,
                                    ),
                                    Text(
                                      'Visa',
                                      style: boldTextStyle(
                                        13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ).pOnly(l: 10, r: 10, t: 10, b: 7),
                          ).pOnly(l: index == 0 ? 17 : 5, t: 2, b: 2);
                        },
                      ),
                    ),
                  ],
                ).mOnly(b: 25, t: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
