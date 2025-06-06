// Importing necessary packages for exports, text styles, extensions, and Cupertino widgets

import 'package:book_store/Core/Theme/app_color.dart';
import 'package:book_store/Core/widgets/book_widget_category.dart';
import 'package:book_store/Model/book_model.dart';
import 'package:book_store/core/theme/text_style.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// import '../../Export/export.dart';

export 'package:book_store/Core/Theme/text_style.dart';

// Defines the PlayPageView as a stateless widget
class PlayPageView extends StatelessWidget {
  // Book model to display in the play page
  final BookModel book;
  // Constructor with required book parameter and optional key parameter
  const PlayPageView({required this.book, super.key});

  @override
  // Builds the UI for the PlayPageView
  Widget build(BuildContext context) {
    // Returns a Container widget for the main structure
    return Container(
      // Applies background color and rounded corners
      decoration: BoxDecoration(
        color: BookStoreColors.veryLightSand,
        borderRadius: BorderRadius.circular(25),
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      // Column to arrange content vertically
      child: Column(
        children: [
          // Adds vertical spacing of 40 units
          40.hBox,
          // Custom widget to display the book cover
          BookWidgetCategory(
            bookLeftVerticalStrip:
                book.colorSet.bookLeftVerticalStrip, // Left strip color
            bookBottomHorizontalStrip:
                book.colorSet.bookBottomHorizontalStrip, // Bottom strip color
            bookPagesColor: book.colorSet.bookPagesColor, // Pages color
            showBookMark: false, // Hides bookmark
            // Book cover image
            bookCover: Image.asset(book.assetPath, fit: BoxFit.fill),
            width: 200, // Sets width of the book widget
          ),
          // Adds vertical spacing of 35 units
          35.hBox,
          // Displays audio visualizer image
          Image.asset(
            'images/audio_visualizer.png',
            width: 290,
            fit: BoxFit.fitWidth,
          ),
          // Row for playback time indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Displays current playback time
              Text(
                '12:22',
                style: boldTextStyle(color: BookStoreColors.mediumRed, 13),
              ),
              // Displays remaining playback time
              Text(
                '-05:20',
                style: boldTextStyle(color: BookStoreColors.mediumRed, 13),
              ),
            ],
          ).pH(32), // Applies horizontal padding of 32 units
          // Adds vertical spacing of 30 units
          30.hBox,
          // Displays book title
          Text(
            book.name,
            style: boldTextStyle(color: BookStoreColors.darkBrown, 23),
          ),
          // Adds vertical spacing of 5 units
          5.hBox,
          // Displays book author
          Text(
            book.author,
            style: TextStyle(
              color: BookStoreColors.mediumRed,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Adds vertical spacing of 32 units
          32.hBox,
          // Row for playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Repeat icon for playback control
              Icon(
                CupertinoIcons.repeat,
                color: BookStoreColors.darkBrown.withValues(alpha: .5),
                size: 25,
              ),
              // Backward skip icon
              Icon(
                CupertinoIcons.backward_end,
                color: BookStoreColors.darkBrown.withValues(alpha: .5),
                size: 25,
              ),
              // Play button with gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      BookStoreColors.mediumRed,
                      BookStoreColors.lightRed,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                // Padding for the play button
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 14,
                  left: 15,
                  right: 13,
                ),
                // Displays play icon
                child: Icon(
                  CupertinoIcons.play_arrow_solid,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              // Forward skip icon
              Icon(
                CupertinoIcons.forward_end,
                color: BookStoreColors.darkBrown.withValues(alpha: .5),
                size: 25,
              ),
              // Share icon
              Icon(
                CupertinoIcons.share,
                color: BookStoreColors.darkBrown.withValues(alpha: .5),
                size: 25,
              ),
            ],
          ).pH(26), // Applies horizontal padding of 26 units
        ],
      ),
    ).pH(28).pOnly(t: 75, b: 100); // Applies padding to the entire widget
  }
}
