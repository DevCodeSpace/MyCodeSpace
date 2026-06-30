import 'package:ai_avtar_chat/core/utils/import_to_export.dart';
import 'package:ai_avtar_chat/modules/assistant/controller/conversation_controller.dart';
import 'package:ai_avtar_chat/modules/assistant/model/gift_card_keyword_search_model.dart';
import 'package:anam_flutter_sdk/anam_flutter_sdk.dart';

// ─── Brand colours for this screen (fully distinct from Govava's red/green) ───
const Color _kBg = Color(0xFF0D0D1A); // deep-space navy
const Color _kSurface = Color(0xFF151528); // card/panel background
const Color _kPrimary = Color(0xFF6C3CE1); // indigo-violet
const Color _kPrimaryLight = Color(0xFF9B6DFF); // lighter violet accent
const Color _kAiBubble = Color(0xFF1C1C35); // AI message bubble
const Color _kTextPrimary = Colors.white;
const Color _kTextSec = Color(0xFF8B95A8); // muted label colour
const Color _kBorder = Color(0xFF252542); // subtle divider/border

/// The one-screen gift-suggestion chat powered by the real-time AI avatar.
/// Layout (top → bottom):
///   • Header bar (title + live pill)
///   • Avatar panel – video when connected, animated placeholder when idle
///   • Gift area – shimmer skeletons while searching, gift grid when results
///     arrive, a hint while chatting, and a how-it-works card when idle
///   • Action bar – "Start Chat" button or mic/end controls
class AvatarChatScreen extends StatefulWidget {
  const AvatarChatScreen({super.key});

  @override
  State<AvatarChatScreen> createState() => _AvatarChatScreenState();
}

class _AvatarChatScreenState extends State<AvatarChatScreen> with SingleTickerProviderStateMixin {
  // Pulsing animation shown on the idle avatar placeholder.
  late AnimationController _pulse;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Pulse: scale 0.92 → 1.08 on a 2-second loop.
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assistant = Get.find<AssistantController>();
    final convo = Get.find<ConversationController>();

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(assistant: assistant),
            const SizedBox(height: 12),
            _AvatarPanel(assistant: assistant, pulseAnim: _pulseAnim),
            const SizedBox(height: 12),
            // Gift area – fills the remaining space and reacts to the search
            // lifecycle: shimmer skeletons while a search is in flight, the
            // results grid when products arrive, and contextual hints otherwise.
            Expanded(
              child: Obx(() {
                final Widget child;
                if (convo.isFetching.value) {
                  child = const _GiftLoadingState(key: ValueKey('gift-loading'));
                } else if (convo.giftProducts.isNotEmpty) {
                  child = _GiftCardsGrid(key: const ValueKey('gift-grid'), products: convo.giftProducts);
                } else if (assistant.isConnected.value || assistant.isConnecting.value) {
                  child = const _GiftIdleHint(key: ValueKey('gift-hint'));
                } else {
                  child = const _HowItWorksCard(key: ValueKey('how-it-works'));
                }
                return AnimatedSwitcher(duration: const Duration(milliseconds: 300), switchInCurve: Curves.easeOut, switchOutCurve: Curves.easeIn, child: child);
              }),
            ),
            _ActionBar(assistant: assistant),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Header bar
// ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.assistant});
  final AssistantController assistant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // App icon – gradient square with gift icon.
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_kPrimary, _kPrimaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [BoxShadow(color: _kPrimary.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))],
            ),
            child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gift Assistant',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: _kTextPrimary),
              ),
              // Status line reacts to controller state.
              Obx(() => Text(_statusLabel(assistant), style: GoogleFonts.poppins(fontSize: 11, color: _statusColor(assistant)))),
            ],
          ),
          const Spacer(),
          // "Live" pill – visible only while connected.
          Obx(() {
            if (!assistant.isConnected.value) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Live',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF22C55E)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _statusLabel(AssistantController c) {
    if (c.isClosingSession.value) return 'Ending chat…';
    if (c.isConnecting.value) return 'Connecting…';
    if (c.isConnected.value && !c.isAnamStreamReady.value) {
      return 'Loading avatar…';
    }
    if (c.isConnected.value) return 'Ask me anything!';
    return 'Tap Start to find a gift';
  }

  Color _statusColor(AssistantController c) {
    if (c.isClosingSession.value || c.isConnecting.value || (c.isConnected.value && !c.isAnamStreamReady.value)) {
      return const Color(0xFFFBBF24); // amber while loading
    }
    if (c.isConnected.value) return const Color(0xFF22C55E); // green when live
    return _kTextSec;
  }
}

// ─────────────────────────────────────────────────────────────────
//  Avatar panel (top card)
// ─────────────────────────────────────────────────────────────────

class _AvatarPanel extends StatelessWidget {
  const _AvatarPanel({required this.assistant, required this.pulseAnim});
  final AssistantController assistant;
  final Animation<double> pulseAnim;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ready = assistant.isAnamStreamReady.value;
      final connecting = assistant.isConnecting.value || assistant.isConnected.value;

      return Container(
        height: 210,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: ready ? _kPrimary.withValues(alpha: 0.55) : _kBorder, width: 1.5),
          // Soft glow appears once the avatar stream is live.
          boxShadow: ready ? [BoxShadow(color: _kPrimary.withValues(alpha: 0.35), blurRadius: 28, spreadRadius: 2)] : null,
        ),
        clipBehavior: Clip.hardEdge,
        child: ready
            ? AnamAvatarView(
                renderer: assistant.renderer,
                isMicEnabled: false,
                showControls: false,
                borderRadius: 24,
                backgroundColor: _kSurface,
                // Cover fit fills the panel edge-to-edge instead of
                // letterboxing the stream with black bars on the sides.
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              )
            : _placeholder(connecting),
      );
    });
  }

  Widget _placeholder(bool connecting) {
    if (connecting) {
      // Spinner while session negotiation is in progress.
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 52, height: 52, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(_kPrimaryLight))),
            const SizedBox(height: 16),
            Text('Waking up Ava…', style: GoogleFonts.poppins(fontSize: 13, color: _kTextSec)),
          ],
        ),
      );
    }

    // Idle: pulsing violet circle with robot icon.
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, child) => Center(
        child: Transform.scale(
          scale: pulseAnim.value,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kPrimary, _kPrimaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: _kPrimary.withValues(alpha: 0.5), blurRadius: 32, spreadRadius: 6)],
                ),
                child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 42),
              ),
              const SizedBox(height: 14),
              Text(
                'Ava  •  Gift AI',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: _kTextPrimary),
              ),
              const SizedBox(height: 4),
              Text('Tap Start Chat to begin', style: GoogleFonts.poppins(fontSize: 12, color: _kTextSec)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Gift cards grid area
// ─────────────────────────────────────────────────────────────────

/// Displays the recommended gifts in a grid format, taking up available screen space.
class _GiftCardsGrid extends StatelessWidget {
  const _GiftCardsGrid({super.key, required this.products});
  // The list now contains strongly-typed GiftItem objects, not generic Maps.
  final List<GiftItem> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kPrimary, _kPrimaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: _kPrimary.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 8))],
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended Gifts',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: _kTextPrimary),
                    ),
                    Text(
                      'Picked from your conversation',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: _kTextSec),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _kPrimaryLight.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _kPrimaryLight.withValues(alpha: 0.28)),
                ),
                child: Text(
                  '${products.length} found',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: _kPrimaryLight),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 14, childAspectRatio: 0.72),
            itemCount: products.length,
            itemBuilder: (_, i) => _GiftCard(product: products[i]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Single gift card
// ─────────────────────────────────────────────────────────────────

class _GiftCard extends StatelessWidget {
  const _GiftCard({required this.product});
  // This widget now receives a type-safe GiftItem object.
  final GiftItem product;

  @override
  Widget build(BuildContext context) {
    // Data Extraction: Safely retrieve product attributes for rendering.
    final String? imageUrl = product.productImages.isNotEmpty ? product.productImages.first : null;
    final String emoji = _categoryEmoji(product.categoryName);
    final String name = product.productName ?? 'Gift';
    final String price = _formatPrice(product.price);
    final String category = product.categoryName ?? 'Gift Pick';

    // Interactive wrapper: Opens the Product Details Bottom Sheet on tap.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showProductDetails(context, product, imageUrl, emoji, name, price),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1A1A31), Color(0xFF121222)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _kPrimaryLight.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.34), blurRadius: 18, offset: const Offset(0, 10)),
              BoxShadow(color: _kPrimary.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: _kAiBubble,
                              gradient: LinearGradient(
                                colors: [_kPrimary.withValues(alpha: 0.18), _kPrimaryLight.withValues(alpha: 0.08)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => _GiftImageFallback(emoji: emoji),
                                    loadingBuilder: (_, child, progress) => progress == null
                                        ? child
                                        : const Center(
                                            child: SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(strokeWidth: 1.8, valueColor: AlwaysStoppedAnimation(_kPrimaryLight)),
                                            ),
                                          ),
                                  )
                                : _GiftImageFallback(emoji: emoji),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(
                              colors: [Colors.black.withValues(alpha: 0.0), Colors.black.withValues(alpha: 0.36)],
                              begin: Alignment.center,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 12, offset: const Offset(0, 6))],
                          ),
                          child: const Icon(Icons.card_giftcard_rounded, color: _kPrimary, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kTextPrimary, height: 1.22),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              category,
                              style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w600, color: _kTextSec),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 28,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: _kPrimaryLight.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _kPrimaryLight.withValues(alpha: 0.22)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            price.isNotEmpty ? price : 'View',
                            style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w800, color: _kPrimaryLight),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.touch_app_rounded, color: _kPrimaryLight, size: 14),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Tap for details',
                            style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w600, color: _kPrimaryLight),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: _kTextSec, size: 11),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GiftImageFallback extends StatelessWidget {
  const _GiftImageFallback({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 36)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Gift area states: loading skeleton / live hint / idle how-it-works
// ─────────────────────────────────────────────────────────────────

/// Shown while the gift search API call is in flight: a "finding gifts"
/// header plus a shimmering skeleton grid that mirrors the results layout.
class _GiftLoadingState extends StatefulWidget {
  const _GiftLoadingState({super.key});

  @override
  State<_GiftLoadingState> createState() => _GiftLoadingStateState();
}

class _GiftLoadingStateState extends State<_GiftLoadingState> with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kPrimary, _kPrimaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Finding perfect gifts…',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: _kTextPrimary),
                    ),
                    Text(
                      'Ava is searching the catalog for you',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: _kTextSec),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 14, childAspectRatio: 0.72),
            itemCount: 4,
            itemBuilder: (_, _) => _SkeletonGiftCard(shimmer: _shimmer),
          ),
        ),
      ],
    );
  }
}

/// Skeleton placeholder matching the proportions of a real [_GiftCard].
class _SkeletonGiftCard extends StatelessWidget {
  const _SkeletonGiftCard({required this.shimmer});

  final Animation<double> shimmer;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (_, _) {
        final t = shimmer.value;
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1A1A31), Color(0xFF121222)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _kPrimaryLight.withValues(alpha: 0.10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _ShimmerBox(t: t, radius: 14)),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(t: t, height: 12, radius: 6),
                    const SizedBox(height: 6),
                    _ShimmerBox(t: t, height: 12, width: 90, radius: 6),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _ShimmerBox(t: t, height: 24, radius: 8)),
                        const SizedBox(width: 8),
                        _ShimmerBox(t: t, height: 24, width: 52, radius: 8),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A single shimmer block: a violet highlight sweeps left → right as [t]
/// progresses through one animation cycle.
class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.t, this.width, this.height, this.radius = 8});

  final double t;
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final dx = -1.5 + 3.0 * t;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(dx - 1, 0),
          end: Alignment(dx + 1, 0),
          colors: [Colors.white.withValues(alpha: 0.05), _kPrimaryLight.withValues(alpha: 0.16), Colors.white.withValues(alpha: 0.05)],
        ),
      ),
    );
  }
}

/// Shown while the session is live but no gift search has produced results
/// yet, so the space below the avatar doesn't sit empty.
class _GiftIdleHint extends StatelessWidget {
  const _GiftIdleHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_kPrimary.withValues(alpha: 0.30), _kPrimaryLight.withValues(alpha: 0.12)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
                border: Border.all(color: _kPrimary.withValues(alpha: 0.35)),
                boxShadow: [BoxShadow(color: _kPrimary.withValues(alpha: 0.25), blurRadius: 26, spreadRadius: 2)],
              ),
              child: const Icon(Icons.card_giftcard_rounded, color: _kPrimaryLight, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              'Gift ideas will appear here',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _kTextPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              "Tell Ava who you're shopping for — she'll pull picks in seconds.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, color: _kTextSec, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown before a session starts: a quick three-step explainer so the idle
/// screen doesn't feel bare.
class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard({super.key});

  static const List<(IconData, String, String)> _steps = [
    (Icons.play_circle_outline_rounded, 'Start the chat', 'Ava greets you live on video.'),
    (Icons.record_voice_over_rounded, 'Describe the person', 'Mention the occasion, age, and interests.'),
    (Icons.card_giftcard_rounded, 'Get instant picks', 'A curated gift grid appears right here.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How it works',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: _kTextPrimary),
              ),
              const SizedBox(height: 14),
              for (final (i, step) in _steps.indexed) ...[
                if (i > 0) const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _kPrimary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _kPrimary.withValues(alpha: 0.25)),
                      ),
                      child: Icon(step.$1, color: _kPrimaryLight, size: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.$2,
                            style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: _kTextPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(step.$3, style: GoogleFonts.poppins(fontSize: 11, color: _kTextSec, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Presentation Helpers
// ─────────────────────────────────────────────────────────────────

/// Bottom Sheet Logic: Displays a detailed view of the selected gift product.
/// This provides a premium, customized dark-theme overlay when a user taps a grid item.
void _showProductDetails(BuildContext context, GiftItem product, String? imageUrl, String emoji, String name, String price) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final mediaQuery = MediaQuery.of(ctx);
      return FractionallySizedBox(
        heightFactor: 0.9,
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF0B0B17), Color(0xFF111126)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 14, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 52,
                          height: 5,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(99)),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: const Icon(Icons.close_rounded, color: _kTextPrimary, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: mediaQuery.size.height * 0.6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 310,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              colors: [_kPrimary.withValues(alpha: 0.24), _kPrimaryLight.withValues(alpha: 0.12), const Color(0xFF111126)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            boxShadow: [BoxShadow(color: _kPrimary.withValues(alpha: 0.16), blurRadius: 26, offset: const Offset(0, 16))],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => _ProductHeroFallback(emoji: emoji),
                                        loadingBuilder: (_, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(
                                            child: SizedBox(
                                              width: 26,
                                              height: 26,
                                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(_kPrimaryLight)),
                                            ),
                                          );
                                        },
                                      )
                                    : _ProductHeroFallback(emoji: emoji),
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.black.withValues(alpha: 0.0), Colors.black.withValues(alpha: 0.26), Colors.black.withValues(alpha: 0.72)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                left: 16,
                                child: _SheetBadge(icon: Icons.auto_awesome_rounded, label: 'AI picked', background: Colors.white.withValues(alpha: 0.12)),
                              ),
                              if (price.isNotEmpty)
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: _SheetBadge(icon: Icons.sell_rounded, label: price, background: _kPrimary.withValues(alpha: 0.32)),
                                ),
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.poppins(fontSize: 23, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),

                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 8,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(emoji, style: const TextStyle(fontSize: 14)),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  product.categoryName ?? 'Gift pick',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.24),
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                          ),
                                          child: Text(
                                            'Recommended for you',
                                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _kTextPrimary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Curated from your conversation',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: _kPrimaryLight, letterSpacing: 0.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This pick is designed to feel personal, premium, and easy to act on. It keeps the focus on the gift while giving you a polished preview before checkout.',
                          style: GoogleFonts.poppins(fontSize: 13.5, color: _kTextSec, height: 1.6),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _InfoChip(icon: Icons.favorite_rounded, label: 'Great match'),
                            _InfoChip(icon: Icons.celebration_rounded, label: 'Gift-ready'),
                            _InfoChip(icon: Icons.bolt_rounded, label: 'Fast decision'),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [_kPrimary.withValues(alpha: 0.95), _kPrimaryLight.withValues(alpha: 0.95)]),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ready to explore more?',
                                      style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700, color: _kTextPrimary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Tap Buy Now to continue with this recommended gift.', style: GoogleFonts.poppins(fontSize: 11.5, height: 1.4, color: _kTextSec)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _kTextPrimary,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: Colors.white.withValues(alpha: 0.03),
                        ),
                        child: Text('Close', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          Get.snackbar('Processing', 'Opening purchase link...', snackPosition: SnackPosition.BOTTOM, backgroundColor: _kSurface, colorText: _kTextPrimary);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [_kPrimary, _kPrimaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: _kPrimary.withValues(alpha: 0.32), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: Center(
                            child: Text(
                              'Buy Now',
                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
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
  );
}

class _SheetBadge extends StatelessWidget {
  const _SheetBadge({required this.icon, required this.label, required this.background});

  final IconData icon;
  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _kPrimaryLight, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: _kTextPrimary),
          ),
        ],
      ),
    );
  }
}

class _ProductHeroFallback extends StatelessWidget {
  const _ProductHeroFallback({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_kPrimary.withValues(alpha: 0.32), _kPrimaryLight.withValues(alpha: 0.14), const Color(0xFF111126)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 24, offset: const Offset(0, 12))],
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 56)),
        ),
      ),
    );
  }
}

/// Formats a raw price string into a display-ready "$XX" or "$XX.XX" label.
String _formatPrice(String? price) {
  if (price == null || price.isEmpty) return '';
  if (price.startsWith('\$') || price.startsWith('£') || price.startsWith('€') || price.startsWith('₹')) {
    return price;
  }
  final parsed = double.tryParse(price);
  if (parsed == null) return '\$$price';
  final formatted = parsed == parsed.truncateToDouble() ? parsed.toStringAsFixed(0) : parsed.toStringAsFixed(2);
  return '\$$formatted';
}

/// Returns a representative emoji for a product category name.
String _categoryEmoji(String? category) {
  final c = (category ?? '').toLowerCase();
  if (c.contains('tech') || c.contains('electronic') || c.contains('gadget')) {
    return '💻';
  }
  if (c.contains('audio') || c.contains('headphone') || c.contains('speaker')) {
    return '🎧';
  }
  if (c.contains('watch') || c.contains('wearable')) return '⌚';
  if (c.contains('beauty') || c.contains('skincare') || c.contains('cosmetic')) {
    return '✨';
  }
  if (c.contains('fashion') || c.contains('cloth') || c.contains('apparel')) {
    return '👗';
  }
  if (c.contains('jewel') || c.contains('accessory') || c.contains('accessories')) {
    return '💍';
  }
  if (c.contains('toy') || c.contains('game') || c.contains('gaming')) {
    return '🎮';
  }
  if (c.contains('book') || c.contains('movie') || c.contains('music') || c.contains('stationery')) {
    return '📚';
  }
  if (c.contains('paper') || c.contains('party') || c.contains('greeting') || c.contains('card')) {
    return '🎉';
  }
  if (c.contains('office') || c.contains('school') || c.contains('supply')) {
    return '📎';
  }
  if (c.contains('food') || c.contains('gourmet') || c.contains('hamper')) {
    return '🎁';
  }
  if (c.contains('sport') || c.contains('fitness') || c.contains('wellness')) {
    return '🏋️';
  }
  if (c.contains('home') || c.contains('decor') || c.contains('kitchen') || c.contains('living')) {
    return '🏠';
  }
  if (c.contains('plant') || c.contains('garden') || c.contains('flower')) {
    return '🌿';
  }
  if (c.contains('pet')) return '🐾';
  if (c.contains('travel') || c.contains('bag') || c.contains('luggage')) {
    return '✈️';
  }
  if (c.contains('instrument')) return '🎵';
  return '🎁';
}

// ─────────────────────────────────────────────────────────────────
//  Bottom action bar
// ─────────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.assistant});
  final AssistantController assistant;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final connected = assistant.isConnected.value;
      final connecting = assistant.isConnecting.value;
      final closing = assistant.isClosingSession.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: _kBorder)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, -8))],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: connected
              ? _connectedRow(key: const ValueKey('call-controls'))
              : _startButton(connecting || closing, context, closing: closing, key: const ValueKey('start-button')),
        ),
      );
    });
  }

  /// Video-call style controls shown while the session is live:
  /// mic toggle on the left, red hang-up in the middle.
  Widget _connectedRow({Key? key}) {
    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(() {
          final micOn = assistant.isMicEnabled.value;
          return _CallControlButton(
            icon: micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
            label: micOn ? 'Mic On' : 'Muted',
            gradient: micOn ? const LinearGradient(colors: [_kPrimary, _kPrimaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
            color: micOn ? null : const Color(0xFF2A2A45),
            glowColor: micOn ? _kPrimary : null,
            onTap: assistant.toggleMic,
          );
        }),
        const SizedBox(width: 44),
        _CallControlButton(
          icon: Icons.call_end_rounded,
          label: 'End',
          gradient: const LinearGradient(colors: [Color(0xFFF87171), Color(0xFFDC2626)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          glowColor: const Color(0xFFEF4444),
          onTap: () => assistant.finalizeAndClose(AssistantController.reasonUserEnded),
        ),
      ],
    );
  }

  /// Full-width gradient "Start Chat" button when idle.
  Widget _startButton(bool connecting, BuildContext context, {bool closing = false, Key? key}) {
    return GestureDetector(
      key: key,
      onTap: connecting
          ? null
          : () {
              // Clear previously searched gift products before starting a new conversation.
              Get.find<ConversationController>().giftProducts.clear();
              assistant.startAssistant(context, showOverlay: false);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: connecting ? null : const LinearGradient(colors: [_kPrimary, _kPrimaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
          color: connecting ? _kAiBubble : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: connecting ? null : [BoxShadow(color: _kPrimary.withValues(alpha: 0.45), blurRadius: 22, offset: const Offset(0, 10))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (connecting)
              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            else
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
              ),
            const SizedBox(width: 10),
            Text(
              closing ? 'Ending…' : (connecting ? 'Starting…' : 'Start Chat'),
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Circular call-control button (mic / end call)
// ─────────────────────────────────────────────────────────────────

class _CallControlButton extends StatelessWidget {
  const _CallControlButton({required this.icon, required this.label, required this.onTap, this.gradient, this.color, this.glowColor});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Gradient? gradient;
  final Color? color;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: gradient,
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                boxShadow: glowColor != null ? [BoxShadow(color: glowColor!.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 8))] : null,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11.5, color: _kTextSec, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
