// Importing necessary packages for text styles, exports, and extensions

import 'package:dart_extensions_pro/dart_extensions_pro.dart';

import '../../Export/export.dart';

// Defines the BooksPageView as a stateless widget
class BooksPageView extends StatelessWidget {
  // Callback function to open a book in play mode
  final Function(BookModel) openPlayWithBook;
  // Constructor with required openPlayWithBook callback and optional key parameter
  const BooksPageView({required this.openPlayWithBook, super.key});

  @override
  // Builds the UI for the BooksPageView
  Widget build(BuildContext context) {
    // Returns a PageView for swipeable content
    return PageView(
      children: [
        // SingleChildScrollView for scrollable content
        SingleChildScrollView(
          child: Column(
            children: [
              // Header widget with left padding
              Header().pOnly(l: 18),
              // SizedBox for search bar and icon
              SizedBox(
                height: 47,
                // Row for search input and search icon
                child: Row(
                  children: [
                    // Expanded widget for search TextField
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        // Container for search input
                        child: Container(
                          color:
                              BookStoreColors
                                  .mediumSand, // Sets background color
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search for books',
                              // Styles the hint text
                              hintStyle: boldTextStyle(
                                color: BookStoreColors.darkBrown,
                                14,
                              ),
                              border:
                                  InputBorder.none, // Removes default border
                              contentPadding: EdgeInsets.only(
                                left: 25,
                                bottom: 5,
                              ), // Adjusts text padding
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Adds horizontal spacing of 15 units
                    15.wBox,
                    // Container for search icon
                    Container(
                      height: 47,
                      width: 47,
                      // Applies gradient background
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            BookStoreColors.mediumRed,
                            BookStoreColors.lightRed.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      // Displays search icon
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                  ],
                ),
              ).pH(18), // Applies horizontal padding of 18 units
              // Adds vertical spacing of 20 units
              20.hBox,
              // SizedBox for horizontal book categories list
              SizedBox(
                height: 100,
                // ListView.builder for horizontal scrolling of book categories
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18,
                  ), // Horizontal padding
                  scrollDirection:
                      Axis.horizontal, // Enables horizontal scrolling
                  itemCount: dummyBooksCategory.length, // Number of categories
                  itemBuilder: (context, index) {
                    final book = dummyBooksCategory[index]; // Current category
                    // Container for each category item
                    return Container(
                      width: 40,
                      margin: const EdgeInsets.only(right: 24), // Right margin
                      // Column to arrange category icon and name
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Container for category icon
                          Container(
                            // Applies shadow for non-'All' categories
                            decoration: BoxDecoration(
                              boxShadow:
                                  book.name.toLowerCase() == 'all'
                                      ? null
                                      : [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.15,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(.5, .5),
                                        ),
                                      ],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            // Displays 'All' widget or category-specific widget
                            child:
                                book.name.toLowerCase() == 'all'
                                    ? Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      // Small widget for 'All' category
                                      child: AllBooksWidgetSmall(),
                                    )
                                    : BookWidgetCategory(
                                      bookPagesColor:
                                          BookStoreColors.pagesColor,
                                      bookLeftVerticalStrip:
                                          book.colorSet.bookLeftVerticalStrip,
                                      bookBottomHorizontalStrip:
                                          book
                                              .colorSet
                                              .bookBottomHorizontalStrip,
                                      // Book cover with icon and color
                                      bookCover: Container(
                                        color: book
                                            .colorSet
                                            .bookLeftVerticalStrip
                                            .withValues(alpha: 0.7),
                                        child: book.icon,
                                      ),
                                      showBookMark: true,
                                      width: 33,
                                    ),
                          ),
                          // Adds vertical spacing of 2 units
                          2.hBox,
                          // Displays category name
                          Text(
                            book.name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.gentiumBookPlus().copyWith(
                              color: BookStoreColors.darkBrown,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Adds vertical spacing of 10 units
              10.hBox,
              // SizedBox for 'Popular' books section header
              SizedBox(
                height: 40,
                // Row for section title and navigation controls
                child: Row(
                  children: [
                    // Expanded widget for section title
                    Expanded(
                      child: Text(
                        'Popular',
                        style: GoogleFonts.gentiumBookPlus().copyWith(
                          color: BookStoreColors.darkBrown,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // Clipped container for 'View All' button
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Container(
                        width: 90,
                        height: 40,
                        color:
                            BookStoreColors
                                .veryLightSand, // Sets background color
                        alignment: Alignment.center,
                        // Displays 'View All' text
                        child: Text(
                          'View All',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.gentiumBookPlus().copyWith(
                            color: BookStoreColors.darkBrown,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    // Adds horizontal spacing of 5 units
                    const SizedBox(width: 5),
                    // Clipped container for backward arrow
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Container(
                        width: 40,
                        height: 40,
                        color:
                            BookStoreColors
                                .veryLightSand, // Sets background color
                        // Displays backward arrow icon
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: BookStoreColors.darkBrown,
                          size: 18,
                        ),
                      ),
                    ),
                    // Adds horizontal spacing of 5 units
                    const SizedBox(width: 5),
                    // Clipped container for forward arrow
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Container(
                        width: 40,
                        height: 40,
                        color:
                            BookStoreColors
                                .veryLightSand, // Sets background color
                        // Displays forward arrow icon
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: BookStoreColors.darkBrown,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ).pH(18), // Applies horizontal padding of 18 units
              ),
              // Adds vertical spacing of 20 units
              20.hBox,
              // SizedBox for horizontal 'Popular' books list
              SizedBox(
                height: 240,
                // ListView.builder for horizontal scrolling of popular books
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 18), // Left padding
                  scrollDirection:
                      Axis.horizontal, // Enables horizontal scrolling
                  itemCount: dummyBooks.length, // Number of books
                  itemBuilder: (context, index) {
                    final book = dummyBooks[index]; // Current book
                    // GestureDetector for book selection
                    return GestureDetector(
                      onTap: () {
                        openPlayWithBook(book); // Calls callback to open book
                      },
                      // Container for each book item
                      child: Container(
                        width: 100,
                        height: 240,
                        margin: const EdgeInsets.only(
                          right: 24,
                        ), // Right margin
                        // Column to arrange book widget and details
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Custom widget for displaying book
                            BookWidgetBig(
                              bookPagesColor: BookStoreColors.pagesColor,
                              bookLeftVerticalStrip:
                                  book.colorSet.bookLeftVerticalStrip,
                              bookBottomHorizontalStrip:
                                  book.colorSet.bookBottomHorizontalStrip,
                              // Book cover image
                              bookCover: Image.asset(
                                book.assetPath,
                                fit: BoxFit.cover,
                              ),
                              showBookMark: true,
                              width: 150,
                            ),
                            // Padding for book details
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              // Column for book name and author
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Adds vertical spacing of 2 units
                                  const SizedBox(height: 2),
                                  // Displays book name
                                  Text(
                                    book.name,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.gentiumBookPlus()
                                        .copyWith(
                                          color: BookStoreColors.darkBrown,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                  ),
                                  // Adds vertical spacing of 1 unit
                                  const SizedBox(height: 1),
                                  // Displays book author
                                  Text(
                                    book.author,
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.gentiumBookPlus()
                                        .copyWith(
                                          color: BookStoreColors.mediumRed,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Adds vertical spacing of 10 units
              10.hBox,
              // SizedBox for 'eBooks' section header
              SizedBox(
                height: 40,
                // Row for section title and navigation controls
                child: Row(
                  children: [
                    // Expanded widget for section title
                    Expanded(
                      child: Text(
                        'eBooks',
                        style: GoogleFonts.gentiumBookPlus().copyWith(
                          color: BookStoreColors.darkBrown,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // Clipped container for 'View All' button
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Container(
                        width: 90,
                        height: 40,
                        color:
                            BookStoreColors
                                .veryLightSand, // Sets background color
                        alignment: Alignment.center,
                        // Displays 'View All' text
                        child: Text(
                          'View All',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.gentiumBookPlus().copyWith(
                            color: BookStoreColors.darkBrown,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    // Adds horizontal spacing of 5 units
                    5.wBox,
                    // Clipped container for backward arrow
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Container(
                        width: 40,
                        height: 40,
                        color:
                            BookStoreColors
                                .veryLightSand, // Sets background color
                        // Displays backward arrow icon
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: BookStoreColors.darkBrown,
                          size: 18,
                        ),
                      ),
                    ),
                    // Adds horizontal spacing of 5 units
                    5.wBox,
                    // Clipped container for forward arrow
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Container(
                        width: 40,
                        height: 40,
                        color:
                            BookStoreColors
                                .veryLightSand, // Sets background color
                        // Displays forward arrow icon
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: BookStoreColors.darkBrown,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ).pH(18), // Applies horizontal padding of 18 units
              ),
              // Adds vertical spacing of 20 units
              20.hBox,
              // SizedBox for horizontal 'eBooks' list
              SizedBox(
                height: 240,
                // ListView.builder for horizontal scrolling of eBooks
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 18), // Left padding
                  scrollDirection:
                      Axis.horizontal, // Enables horizontal scrolling
                  itemCount: dummyEBooks.length, // Number of eBooks
                  itemBuilder: (context, index) {
                    final book = dummyEBooks[index]; // Current eBook
                    // GestureDetector for eBook selection
                    return GestureDetector(
                      onTap: () {
                        openPlayWithBook(book); // Calls callback to open eBook
                      },
                      // SizedBox for each eBook item
                      child: SizedBox(
                        width: 100,
                        height: 240,
                        // Column to arrange eBook widget and details
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Custom widget for displaying eBook
                            BookWidgetBig(
                              bookPagesColor: BookStoreColors.pagesColor,
                              bookLeftVerticalStrip:
                                  book.colorSet.bookLeftVerticalStrip,
                              bookBottomHorizontalStrip:
                                  book.colorSet.bookBottomHorizontalStrip,
                              // eBook cover image
                              bookCover: Image.asset(
                                book.assetPath,
                                fit: BoxFit.cover,
                              ),
                              showBookMark: true,
                              width: 150,
                            ),
                            // Padding for eBook details
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              // Column for eBook name and author
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Adds vertical spacing of 2 units
                                  const SizedBox(height: 2),
                                  // Displays eBook name
                                  Text(
                                    book.name,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.gentiumBookPlus()
                                        .copyWith(
                                          color: BookStoreColors.darkBrown,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                  ),
                                  // Adds vertical spacing of 1 unit
                                  const SizedBox(height: 1),
                                  // Displays eBook author
                                  Text(
                                    book.author,
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.gentiumBookPlus()
                                        .copyWith(
                                          color: BookStoreColors.mediumRed,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).pOnly(r: 24), // Applies right padding of 24 units
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
