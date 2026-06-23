import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smedge/common_files/custom_container.dart';
import 'package:smedge/common_files/network_checker.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/constants/strings.dart';
import 'package:smedge/utils/global_utils.dart';
import 'package:smedge/utils/router/app_routes.dart';

import '../../../provider/provider.dart';
import '../dashboard_state.dart';
import '../dashboard_view_model.dart';
import '../model/products_list_model.dart';
import '../widgets/product_service_bottom_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  double sliderValue = 10.4;
  int monthSlider = 1;
  bool _isCollapsed = false;
  late ScrollController _scrollController;

  static const _gradientColors = [Color(0xff00418F), Color(0xff76B4FF)];
  final GlobalKey _headerKey = GlobalKey();
  double _expandedHeight = 300;

  final List<ProductServiceModel> productList = [
    ProductServiceModel(
      title: "Merchant Finance",
      description: "Instant capital support for your business transactions.",
      icon: Icons.point_of_sale,
      tags: [
        ProductTag(
          label: "Fast Approval",
          backgroundColor: Colors.purple.shade50,
          textColor: Colors.purple,
        ),
        ProductTag(
          label: "Flexible Repayment",
          backgroundColor: Colors.purple.shade50,
          textColor: Colors.purple,
        ),
      ],
      amountText: "250,000",
      subText: "Processing in 24 Hours",
      buttonText: "Apply Now",
    ),
    ProductServiceModel(
      title: "Open SME Account",
      description: "Open a business account with partnered banks.",
      icon: Icons.account_balance,
      tags: [
        ProductTag(
          label: "Zero Balance",
          backgroundColor: Colors.red.shade50,
          textColor: Colors.red,
        ),
        ProductTag(
          label: "Partnered Banks",
          backgroundColor: Colors.red.shade50,
          textColor: Colors.red,
        ),
      ],
      amountText: "Free Activation",
      subText: "",
      buttonText: "Open Account",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      ref.read(dashboardStateProvider).setContext(context);
      _measureHeaderHeight();
      await  _networkCall();
     await Utils.getAllData();
    });

  }

  Future<void> _networkCall() async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();
      if (!hasInternet) {
        Utils.showErrorSnackBar(context, Strings.NO_INTERNET);
        return;
      }
      ref.read(dashboardStateProvider).setLoading(hasInternet);
     await ref.read(personalDetailsNotifier("").future);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      ref.read(dashboardStateProvider).setLoading(false);
    }
  }


  void _measureHeaderHeight() {
    final ctx = _headerKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box != null) {
        setState(() => _expandedHeight = box.size.height - 40);
      }
    }
  }

  void _onScroll() {
    final topPadding = MediaQuery.of(context).padding.top;
    final collapseAt = _expandedHeight - kToolbarHeight - topPadding;
    final collapsed = _scrollController.offset > collapseAt;
    if (collapsed != _isCollapsed) {
      setState(() => _isCollapsed = collapsed);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = ref.watch(dashboardStateProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body:dashboardProvider.isLoading?
      Center(child: CircularProgressIndicator())
          : CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: _expandedHeight,
            pinned: true,
            floating: false,
            automaticallyImplyLeading: false,
            toolbarHeight: kToolbarHeight,
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final topPadding = MediaQuery.of(context).padding.top;
                final isCollapsed =
                    constraints.maxHeight <= kToolbarHeight + topPadding + 2;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: _gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isCollapsed
                        ? _buildCollapsedBar(topPadding)
                        : _buildExpandedHeader(),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Products & Services"),
                  SizedBox(height: Numbers.DOUBLE_NUMBER_10),
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: productList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: MediaQuery.of(context).size.width < 360
                          ? 0.75
                          : 0.88,
                    ),
                    itemBuilder: (context, index) => InkWell(
                      onTap: () {},
                      child: _productCard(productList[index]),
                    ),
                  ),
                  SizedBox(height: Numbers.DOUBLE_NUMBER_20),
                  _sectionTitle("Active Products"),
                  SizedBox(height: Numbers.DOUBLE_NUMBER_10),
                  _activeProductCard(
                    context,
                    activeProducts[0],
                    dashboardProvider,
                  ),
                  SizedBox(height: Numbers.DOUBLE_NUMBER_20),
                  _fundingCalculator(),
                  SizedBox(height: Numbers.DOUBLE_NUMBER_20),
                  _sectionTitle("Quick Info"),
                  SizedBox(height: Numbers.DOUBLE_NUMBER_10),
                  Row(
                    children: [
                      Expanded(child: _quickCard("Prayer Time")),
                      SizedBox(width: Numbers.DOUBLE_NUMBER_10),
                      Expanded(child: _quickCard("Market Overview")),
                      SizedBox(width: Numbers.DOUBLE_NUMBER_10),
                      Expanded(child: _quickCard("Upcoming EMI")),
                    ],
                  ),
                  SizedBox(height: Numbers.DOUBLE_NUMBER_20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedBar(double topPadding) {
    final theme = Theme.of(context);
    return SizedBox(
      key: const ValueKey('collapsed'),
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          top: topPadding + 12,
          left: Numbers.DOUBLE_NUMBER_16,
          right: Numbers.DOUBLE_NUMBER_16,
          bottom: Numbers.DOUBLE_NUMBER_16,
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue, size: 24),
            ),
            SizedBox(width: Numbers.DOUBLE_NUMBER_10),
            Expanded(
              child: Text(Utils.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            _notificationIcon(),
          ],
        ),
      ),
    );
  }



  Widget _buildExpandedHeader() {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    return SingleChildScrollView(
      key: ValueKey('expanded'),
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
        key: _headerKey,
        padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        getGreeting(),
                        style: theme.textTheme.titleLarge!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Seamlessly manage your SME finances",
                        style: theme.textTheme.titleSmall!.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _notificationIcon(),
              ],
            ),
            SizedBox(height: Numbers.DOUBLE_NUMBER_10),
            Row(
              children: List.generate(
                70,
                (i) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0.1),
                    height: 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: i % 2 == 0 ? Colors.white : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: Numbers.DOUBLE_NUMBER_12),
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    Utils.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Numbers.DOUBLE_NUMBER_12),
            Row(
              children: [
                _switchChip("Personal", Colors.amber),
                const SizedBox(width: 10),
                _switchChip("Business", Colors.white),
              ],
            ),
            SizedBox(height: Numbers.DOUBLE_NUMBER_12),
            Container(
              padding: EdgeInsets.symmetric(
                vertical: Numbers.DOUBLE_NUMBER_12,
                horizontal: Numbers.DOUBLE_NUMBER_10,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: _gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(Numbers.DOUBLE_NUMBER_14),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 6,
                    color: Color(0xff00418F),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _HeaderInfo("Customer ID", "GSTIN12345")),
                    _Divider(),
                    Expanded(child: _HeaderInfo("KYC Status", "Verified")),
                    _Divider(),
                    Expanded(child: _HeaderInfo("KYB Status", "Not Verified")),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationIcon() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.notification);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 20,
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              height: 7,
              width: 7,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: Theme.of(context).textTheme.titleLarge!.copyWith(
      color: Theme.of(context).colorScheme.primary,
    ),
  );

  Widget _productCard(ProductServiceModel item) {
    final theme = Theme.of(context);
    return CustomContainer(
      padding: Numbers.DOUBLE_NUMBER_12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(item.icon, color: Colors.blue, size: 20),
              Flexible(
                child: Text(
                  "View Details",
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall!.copyWith(
                    fontSize: Numbers.DOUBLE_NUMBER_12,
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall!.copyWith(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 2,
            children: item.tags.take(2).map((e) => _tag(e)).toList(),
          ),
          const Divider(height: 14, color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    item.title.contains("Merchant")
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Up to ",
                                style: theme.textTheme.titleSmall!.copyWith(
                                  fontSize: 10,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              SvgPicture.asset(
                                "assets/svg/dirham.svg",
                                height: 8,
                                colorFilter: ColorFilter.mode(
                                  theme.colorScheme.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  " ${item.amountText}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall!.copyWith(
                                    fontSize: 10,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            item.amountText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall!.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                    if (item.subText != null && item.subText!.isNotEmpty)
                      Text(
                        item.subText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: ElevatedButton(
                  onPressed: () {
                    if (item.title.contains("Merchant")) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const ProductServiceBottomSheet(),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    item.buttonText,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(ProductTag tag) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: tag.backgroundColor,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(tag.label, style: TextStyle(fontSize: 9, color: tag.textColor)),
  );

  Widget _activeProductCard(
    BuildContext context,
    ActiveProduct product,
    DashboardState dashboardProvider,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: Numbers.DOUBLE_NUMBER_40,
                height: Numbers.DOUBLE_NUMBER_40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FB),
                  borderRadius: BorderRadius.circular(Numbers.DOUBLE_NUMBER_10),
                ),
                child: Icon(
                  Icons.credit_card_outlined,
                  color: theme.colorScheme.primary,
                  size: Numbers.DOUBLE_NUMBER_20,
                ),
              ),
              SizedBox(width: Numbers.DOUBLE_NUMBER_10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: theme.textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                        fontSize: Numbers.DOUBLE_NUMBER_14,
                      ),
                    ),
                    SizedBox(height: Numbers.DOUBLE_NUMBER_2),
                    Text(
                      product.productId,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: const Color(0xFF8A8FAE),
                        fontSize: Numbers.DOUBLE_NUMBER_12,
                      ),
                    ),
                  ],
                ),
              ),
              if (product.isActive)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Numbers.DOUBLE_NUMBER_14,
                    vertical: Numbers.DOUBLE_NUMBER_6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34A853),
                    borderRadius: BorderRadius.circular(
                      Numbers.DOUBLE_NUMBER_20,
                    ),
                  ),
                  child: Text(
                    'Active',
                    style: theme.textTheme.titleSmall!.copyWith(
                      color: Colors.white,
                      fontSize: Numbers.DOUBLE_NUMBER_12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: Numbers.DOUBLE_NUMBER_12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/svg/dirham.svg",
                    height: Numbers.DOUBLE_NUMBER_12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product.remainingAmount
                        .toStringAsFixed(0)
                        .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (m) => '${m[1]},',
                        ),
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Text(
                'remaining',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: const Color(0xFF8A8FAE),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: Numbers.DOUBLE_NUMBER_4),
          Text(
            product.companyName,
            style: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          SizedBox(height: Numbers.DOUBLE_NUMBER_12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Repayment progress',
                style: theme.textTheme.bodySmall!.copyWith(
                  color: const Color(0xFF8A8FAE),
                  fontSize: 12,
                ),
              ),
              Text(
                '${(product.paidInstallments / product.totalInstallments * 100).round()}%',
                style: theme.textTheme.bodySmall!.copyWith(
                  color: const Color(0xFFE67E22),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: Numbers.DOUBLE_NUMBER_6),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: product.paidInstallments / product.totalInstallments,
              minHeight: 7,
              backgroundColor: const Color(0xffE4F0FF),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: Numbers.DOUBLE_NUMBER_6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${product.paidInstallments} of ${product.totalInstallments} paid',
                style: theme.textTheme.bodySmall!.copyWith(
                  color: const Color(0xFF8A8FAE),
                  fontSize: 12,
                ),
              ),
              Text(
                '${product.totalInstallments - product.paidInstallments} remaining',
                style: theme.textTheme.bodySmall!.copyWith(
                  color: const Color(0xFF8A8FAE),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: Numbers.DOUBLE_NUMBER_12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: _infoChip(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/svg/dirham.svg", height: 10),
                      Text(
                        ' ${product.monthlyPayment.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: theme.textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  label: 'Monthly',
                ),
              ),
              SizedBox(width: Numbers.DOUBLE_NUMBER_10),
              Expanded(
                flex: 3,
                child: _infoChip(
                  child: Text(
                    formatDate(product.nextPaymentDate),
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  label: 'Next Payment',
                ),
              ),
              SizedBox(width: Numbers.DOUBLE_NUMBER_10),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: Numbers.DOUBLE_NUMBER_50,
                  child: ElevatedButton(
                    onPressed: () {
                      dashboardProvider.setTabIndex(2);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Numbers.DOUBLE_NUMBER_12,
                        ),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: Numbers.DOUBLE_NUMBER_14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip({required Widget child, required String label}) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: Numbers.DOUBLE_NUMBER_12,
      vertical: Numbers.DOUBLE_NUMBER_8,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFF2F4F7),
      borderRadius: BorderRadius.circular(Numbers.DOUBLE_NUMBER_12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 2),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8A8FAE),
            ),
          ),
        ),
      ],
    ),
  );



  Widget _fundingCalculator() {
    final theme = Theme.of(context);
    return CustomContainer(
      padding: Numbers.DOUBLE_NUMBER_12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.calculate_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  "Funding Calculator",
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: Numbers.DOUBLE_NUMBER_6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text("Amount", style: theme.textTheme.titleSmall),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SvgPicture.asset("assets/svg/dirham.svg", height: 10),
                    Text(
                      " ${sliderValue.toStringAsFixed(2)}",
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Slider(
            padding: EdgeInsets.zero,
            min: 0.0,
            max: 100,
            value: sliderValue,
            inactiveColor: Color(0xffE4F0FF),
            onChanged: (v) => setState(() => sliderValue = v),
          ),
          SizedBox(height: Numbers.DOUBLE_NUMBER_8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Tenure (months)",
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      " $monthSlider ${(monthSlider == 1) ? 'Month' : 'Months'}",
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Slider(
            padding: EdgeInsets.zero,
            min: 1.0,
            max: 12,
            value: monthSlider.toDouble(),
            inactiveColor: Color(0xffE4F0FF),
            onChanged: (v) => setState(() => monthSlider = v.toInt()),
          ),
          SizedBox(height: Numbers.DOUBLE_NUMBER_8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.primary),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Weekly Repayment Amount",
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Indicative - 2.8% flat fee included",
                        style: theme.textTheme.titleSmall!.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SvgPicture.asset("assets/svg/dirham.svg", height: 10),
                      const Text(" 959"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickCard(String text) => Container(
    height: 80,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.blueGrey,
    ),
    child: Text(text, style: const TextStyle(color: Colors.white)),
  );

  Widget _switchChip(String text, Color color) => GestureDetector(
    onTap: () {
      if (text.toLowerCase().contains("personal")) {
        Navigator.pushNamed(context, AppRoutes.personalDetailsScreen);
      } else {
        Navigator.pushNamed(context, AppRoutes.businessDetails);
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            text.toLowerCase().contains("personal")
                ? Icons.person
                : Icons.business_center_outlined,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 10),
        ],
      ),
    ),
  );
}

class _HeaderInfo extends StatelessWidget {
  final String title;
  final String value;

  const _HeaderInfo(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: (value.toLowerCase() == ("verified"))
                ? Colors.green
                : Colors.white,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      Container(height: 30, width: 1, color: Colors.white24);
}

class ActiveProduct {
  final String productName;
  final String productId;
  final String companyName;
  final double remainingAmount;
  final double monthlyPayment;
  final DateTime nextPaymentDate;
  final int totalInstallments;
  final int paidInstallments;
  final bool isActive;

  const ActiveProduct({
    required this.productName,
    required this.productId,
    required this.companyName,
    required this.remainingAmount,
    required this.monthlyPayment,
    required this.nextPaymentDate,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.isActive,
  });

  int get remainingInstallments => totalInstallments - paidInstallments;

  double get repaymentProgress => paidInstallments / totalInstallments;

  int get repaymentPercent => (repaymentProgress * 100).round();
}

final List<ActiveProduct> activeProducts = [
  ActiveProduct(
    productName: 'Merchant Financing',
    productId: 'PS - 12345',
    companyName: 'Edwin Trading LLC',
    remainingAmount: 5900,
    monthlyPayment: 12965,
    nextPaymentDate: DateTime(2026, 5, 1),
    totalInstallments: 6,
    paidInstallments: 2,
    isActive: true,
  ),
  ActiveProduct(
    productName: 'Trade Finance',
    productId: 'TF - 67890',
    companyName: 'ZhongFin Retail Trad...',
    remainingAmount: 18400,
    monthlyPayment: 3680,
    nextPaymentDate: DateTime(2026, 6, 15),
    totalInstallments: 12,
    paidInstallments: 7,
    isActive: true,
  ),
];
