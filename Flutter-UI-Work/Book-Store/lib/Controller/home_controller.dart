import 'package:book_store/Export/export.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  var tabIndex = 0.obs;

  BookModel book = dummyBooks[1];

  void openTab(int index) {
    tabIndex.value = index;
    tabController.animateTo(tabIndex.value);
  }

  void openPlayWithBook(BookModel book) {
    this.book = book;

    openTab(3);
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      initialIndex: tabIndex.value,
      vsync: this,
      length: 5,
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}
