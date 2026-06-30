import 'dart:convert';

// ─── Input model ──────────────────────────────────────────────────────────────

/// Payload sent to POST /customer/search/keyword_search.
/// All fields are optional; at minimum provide [keyword] and [page].
class GiftCardKeywordSearchInputModel {
  /// Free-text search term the AI generated (e.g. "gifts for husband tech lover").
  String? keyword;

  /// Category slug filter (leave null to search across all categories).
  String? category;

  /// 1-based page index for pagination.
  int? page;

  /// ISO country code used to filter region-specific products (e.g. "US").
  String? countryCode;

  /// Product type filter (leave null for all types).
  String? type;

  GiftCardKeywordSearchInputModel({
    this.keyword,
    this.category,
    this.page,
    this.countryCode,
    this.type,
  });

  Map<String, dynamic> toJson() => {
        'keyword': keyword,
        'category': category,
        'page': page,
        'countryCode': countryCode,
        'type': type,
      };

  String toJsonString() => jsonEncode(toJson());
}

// ─── Response model ───────────────────────────────────────────────────────────

/// Top-level wrapper returned by the keyword search API.
class GiftCardKeywordSearchResponseModel {
  /// True when the API call succeeded and [response] contains data.
  bool status;

  /// Null on failure; contains pagination metadata and the item list on success.
  GiftKeywordResponse? response;

  GiftCardKeywordSearchResponseModel({this.status = false, this.response});

  factory GiftCardKeywordSearchResponseModel.fromJson(
      Map<String, dynamic> json) {
    return GiftCardKeywordSearchResponseModel(
      status: json['status'] ?? false,
      response: json['response'] != null
          ? GiftKeywordResponse.fromJson(json['response'])
          : null,
    );
  }
}

// ─── Pagination envelope ──────────────────────────────────────────────────────

/// Pagination metadata and the list of product items.
class GiftKeywordResponse {
  /// Total number of matched products across all pages.
  String? totalMatches;

  /// Total number of available pages.
  String? totalPages;

  /// Current page number (1-based, returned as string by the API).
  String? pageNumber;

  /// Product items for the current page.
  List<GiftItem> item;

  GiftKeywordResponse({
    this.totalMatches,
    this.totalPages,
    this.pageNumber,
    this.item = const [],
  });

  factory GiftKeywordResponse.fromJson(Map<String, dynamic> json) {
    List<GiftItem> items = [];
    if (json['item'] != null) {
      items = (json['item'] as List)
          .map((v) => GiftItem.fromJson(v as Map<String, dynamic>))
          .toList();
    }
    return GiftKeywordResponse(
      totalMatches: json['TotalMatches']?.toString(),
      totalPages: json['TotalPages']?.toString(),
      pageNumber: json['PageNumber']?.toString(),
      item: items,
    );
  }
}

// ─── Product item ─────────────────────────────────────────────────────────────

/// A single product returned by the keyword search endpoint.
///
/// Actual API field names (verified against live response 2026-06-03):
///   productname  — product display name (lowercase 'n')
///   imageurl     — single image URL string (all lowercase)
///   price        — sale price as a string or number (e.g. "18.0")
///   category     — object { primary: "Home & Living", secondary: "..." }
///   productId    — string like "etsy-1484215870" or "amz-B0CR1726KQ"
class GiftItem {
  /// Unique product identifier — kept as String because the API returns composite
  /// IDs like "etsy-1484215870" that cannot be parsed as integers.
  String? productId;

  /// Display name of the product.
  String? productName;

  /// Sale price as a formatted string (e.g. "18.0", "13.99").
  String? price;

  /// Primary category label (extracted from the nested category object).
  String? categoryName;

  /// Product image URLs; the API returns a single 'imageurl' string that we
  /// wrap in a list so the rest of the app can treat it uniformly.
  List<String> productImages;

  GiftItem({
    this.productId,
    this.productName,
    this.price,
    this.categoryName,
    this.productImages = const [],
  });

  factory GiftItem.fromJson(Map<String, dynamic> json) {
    // ── Image ──
    // API sends a single string field "imageurl" (all lowercase).
    // Fall back to camelCase variants used in older API versions.
    List<String> images = [];
    final rawImage = json['imageurl'] ?? json['imageUrl'] ?? json['productImages'] ?? json['productImage'];
    if (rawImage is List) {
      images = rawImage.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    } else if (rawImage is String && rawImage.isNotEmpty) {
      images = [rawImage];
    }

    // ── Category ──
    // API returns category as an object { primary: "...", secondary: "..." }.
    // Fall back to plain string or category_site list if the object is absent.
    String? cat;
    final rawCat = json['category'];
    if (rawCat is Map) {
      // Prefer "primary" label; fall back to "secondary" if primary is absent.
      cat = (rawCat['primary'] ?? rawCat['secondary'])?.toString();
    } else if (rawCat is String && rawCat.isNotEmpty) {
      cat = rawCat;
    }
    if (cat == null || cat.isEmpty) {
      // category_site is a flat list like ["candles", "home decor"] — use first entry.
      final sites = json['category_site'];
      if (sites is List && sites.isNotEmpty) {
        cat = sites.first.toString();
      }
    }

    // ── Price ──
    // Prefer "price" (sale price); fall back to "saleprice" or "actualPrice".
    final rawPrice = json['price'] ?? json['saleprice'] ?? json['actualPrice'];

    return GiftItem(
      // productId is a string like "etsy-1484215870" — store as-is.
      productId: json['productId']?.toString(),
      // API field is "productname" (lowercase n).
      productName: (json['productname'] ?? json['productName'])?.toString(),
      price: rawPrice?.toString(),
      categoryName: cat,
      productImages: images,
    );
  }
}
