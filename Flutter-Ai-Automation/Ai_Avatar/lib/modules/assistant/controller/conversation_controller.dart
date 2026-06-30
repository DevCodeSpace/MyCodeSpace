import 'dart:developer';

import 'package:ai_avtar_chat/core/utils/import_to_export.dart';
import 'package:ai_avtar_chat/core/widgets/popup.dart';
import 'package:ai_avtar_chat/modules/assistant/model/gift_card_keyword_search_model.dart';

/// Manages gift-search state shared between [AssistantController]
/// (which triggers the search via the `search_gifts` tool) and the chat screen
/// (which renders the resulting [giftProducts] list).
class ConversationController extends GetxController {
  // ── Product search state ──

  /// Current page number for paginated results (starts at 1).
  final page = 1.obs;
  final totalPage = 1.obs;
  // Computed alongside totalPage for future load-more support.
  final hasNexPage = true.obs;

  /// True while a search request is in-flight — prevents duplicate fetches.
  final isFetching = false.obs;
  final isDialogOpenAlready = false.obs;

  /// Gift products shown in the gift cards row.
  /// Populated by [searchKeyWord]; cleared on new searches.
  final RxList<GiftItem> giftProducts = <GiftItem>[].obs;

  /// Called by the `search_gifts` tool (and the client-side fallback) with the
  /// AI-generated query. Hits the real keyword search API and populates
  /// [giftProducts] so the chat screen renders the gift-card row.
  Future<void> searchKeyWord(String search) async {
    if (isFetching.value) {
      log("⚠️ searchKeyWord called while already fetching — skipped");
      return;
    }

    isFetching.value = true;
    page.value = 1;
    giftProducts.clear(); // clear stale results before new fetch

    try {
      // Check connectivity before hitting the network.
      if (!await checkConnection()) {
        isFetching.value = false;
        await Get.dialog(customNetworkDialog());
        return;
      }

      // Build the search payload; countryCode defaults to "US".
      final input = GiftCardKeywordSearchInputModel(keyword: search, page: page.value, countryCode: 'US');
      final result = await RestService.giftKeyWordSearch(input);

      if (result.status && result.response != null) {
        // Update total pages for potential load-more support.
        totalPage.value = int.tryParse(result.response!.totalPages ?? '1') ?? 1;
        hasNexPage.value = page.value < totalPage.value;

        giftProducts.assignAll(result.response!.item);
        log("[Search] ${giftProducts.length} products returned for: $search");
      } else {
        log("[Search] API returned no results for: $search");
      }
    } catch (e) {
      log("searchKeyWord error: $e");
    } finally {
      isFetching.value = false;
    }
  }
}
