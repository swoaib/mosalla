import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../model/prayer_data.dart';
import '../pages/events_page.dart';
import '../providers/prayer_time_provider.dart';
import '../providers/theme_provider.dart';
import 'monthly_prayer_calendar.dart';
import 'custom_bottom_navigation_bar.dart';

class PrayerTime extends StatefulWidget {
  const PrayerTime({
    super.key,
    required this.prayerData,
    this.activePrayer,
  });

  final PrayerData prayerData;
  final int? activePrayer;

  @override
  State<PrayerTime> createState() => _PrayerTimeState();
}

class _PrayerTimeState extends State<PrayerTime> {
  double _dragDistance = 0.0;
  bool _slideForward = true;
  DateTime? _lastDate;

  void _changeDate(PrayerTimeProvider provider, bool isNext) {
    HapticFeedback.lightImpact();
    setState(() {
      _slideForward = isNext;
    });
    provider.changeDate(isNext);
  }

  Widget _buildPrayerTile(BuildContext context, int prayerIndex, String name,
      IconData icon, DateTime? adhanTime, DateTime? jamaatTime,
      {bool isSunrise = false,
      bool isJumma = false,
      DateTime? jamaatTime2,
      DateTime? jamaatTime3}) {
    final locale = Localizations.localeOf(context).languageCode;
    final themeProvider = Provider.of<ThemeProvider?>(context, listen: false);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final isTealTheme = (themeProvider?.isTealTheme ?? false) ||
        scaffoldBg == const Color(0xFF00695C) ||
        scaffoldBg == Colors.teal;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDarkBg = isDark || isTealTheme;

    Color activeColor =
        isTealTheme ? const Color(0xFF00BFA5) : Theme.of(context).primaryColor;
    bool isActive =
        widget.activePrayer != null && widget.activePrayer == prayerIndex;

    Color inactiveTextColor = isDarkBg
        ? Colors.white
        : (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87);
    Color inactiveIconColor = isDarkBg
        ? Colors.white.withValues(alpha: 0.85)
        : (isDark ? Colors.white70 : (Colors.grey[700] ?? Colors.grey));

    final adhanStr =
        adhanTime == null ? '- -' : DateFormat.Hm(locale).format(adhanTime);
    List<String> jamaatTimes = [];
    if (jamaatTime != null) {
      jamaatTimes.add(DateFormat.Hm(locale).format(jamaatTime));
    }
    if (jamaatTime2 != null) {
      jamaatTimes.add(DateFormat.Hm(locale).format(jamaatTime2));
    }
    if (jamaatTime3 != null) {
      jamaatTimes.add(DateFormat.Hm(locale).format(jamaatTime3));
    }
    String jamaatStr = jamaatTimes.isEmpty ? '- -' : jamaatTimes.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isActive ? activeColor : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : inactiveIconColor,
            size: 20,
          ),
          const SizedBox(width: 16),
          Text(name,
              style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? Colors.white : inactiveTextColor)),
          const SizedBox(width: 16),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Adhan Column
                if (!isSunrise)
                  SizedBox(
                      width: 60,
                      child: Text(adhanStr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight:
                                  isActive ? FontWeight.bold : FontWeight.w500,
                              color: isActive
                                  ? Colors.white
                                  : inactiveTextColor))),
                if (!isSunrise) const SizedBox(width: 20),

                // Jamaat Column
                Flexible(
                  child: SizedBox(
                      width: isJumma ? null : 60,
                      child: isJumma && !isSunrise && jamaatTimes.isNotEmpty
                          ? Wrap(
                              alignment: WrapAlignment.end,
                              spacing: 10,
                              runSpacing: 4,
                              children: jamaatTimes
                                  .map((t) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? Colors.white
                                                  .withValues(alpha: 0.25)
                                              : (isDarkBg
                                                  ? Colors.white
                                                      .withValues(alpha: 0.15)
                                                  : Colors.grey
                                                      .withValues(alpha: 0.15)),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(t,
                                            style: TextStyle(
                                              color: isActive
                                                  ? Colors.white
                                                  : (isDarkBg
                                                      ? Colors.white
                                                      : inactiveTextColor),
                                            )),
                                      ))
                                  .toList(),
                            )
                          : Text(isSunrise ? ' ' : jamaatStr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isActive
                                      ? Colors.white
                                      : inactiveTextColor))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.watch<PrayerTimeProvider>();
    DateTime date = provider.date;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();

    if (_lastDate != null && !DateUtils.isSameDay(_lastDate, date)) {
      _slideForward = date.isAfter(_lastDate!);
    }
    _lastDate = date;

    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final prayerData = widget.prayerData;

    final themeProvider = Provider.of<ThemeProvider?>(context);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final isTealTheme = (themeProvider?.isTealTheme ?? false) ||
        scaffoldBg == Colors.teal ||
        scaffoldBg == const Color(0xFF00695C);
    final isDarkBg =
        ThemeData.estimateBrightnessForColor(scaffoldBg) == Brightness.dark ||
            isTealTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) {
          _dragDistance = 0.0;
        },
        onHorizontalDragUpdate: (details) {
          _dragDistance += details.primaryDelta ?? 0;
        },
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          const velocityThreshold = 250.0;
          const distanceThreshold = 50.0;
          final isRtl = Directionality.of(context).name == 'rtl';

          if (velocity < -velocityThreshold ||
              _dragDistance < -distanceThreshold) {
            // Swiped left -> Next day
            final isNext = !isRtl;
            _changeDate(provider, isNext);
          } else if (velocity > velocityThreshold ||
              _dragDistance > distanceThreshold) {
            // Swiped right -> Previous day
            final isNext = isRtl;
            _changeDate(provider, isNext);
          }
          _dragDistance = 0.0;
        },
        onHorizontalDragCancel: () {
          _dragDistance = 0.0;
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.filled(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _changeDate(provider, false),
                    style: IconButton.styleFrom(
                      backgroundColor: isDarkBg
                          ? Colors.white.withValues(alpha: 0.2)
                          : Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                      foregroundColor: isDarkBg
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        isScrollControlled: true,
                        builder: (context) {
                          return SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(l10n.selectDate,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  CalendarDatePicker(
                                    initialDate: date,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    onDateChanged: (newDate) {
                                      setState(() {
                                        _slideForward = newDate.isAfter(date);
                                      });
                                      provider.fetchPrayerTimes(
                                          newDate: newDate);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: Column(
                        key: ValueKey<String>(dateKey),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat.MMMMEEEEd(Localizations.localeOf(context)
                                    .languageCode)
                                .format(date),
                            style: TextStyle(
                              color: isDarkBg ? Colors.white : null,
                            ),
                          ),
                          Text(
                            (() {
                              final languageCode =
                                  Localizations.localeOf(context).languageCode;
                              const supportedHijriLocales = [
                                'ar',
                                'en',
                                'id',
                                'tr',
                                'pt'
                              ];
                              final hijriLocale =
                                  supportedHijriLocales.contains(languageCode)
                                      ? languageCode
                                      : 'en';
                              HijriCalendar.setLocal(hijriLocale);
                              return HijriCalendar.fromDate(date)
                                  .toFormat("dd MMMM yyyy");
                            })(),
                            style: TextStyle(
                              color:
                                  isDarkBg ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton.filled(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _changeDate(provider, true),
                    style: IconButton.styleFrom(
                      backgroundColor: isDarkBg
                          ? Colors.white.withValues(alpha: 0.2)
                          : Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                      foregroundColor: isDarkBg
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                key: const PageStorageKey<String>('prayer_time_scroll'),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: CustomBottomNavigationBar.contentBottomPadding +
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRect(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            final isIncoming =
                                (child.key as ValueKey<String>?)?.value ==
                                    dateKey;
                            final inOffset = _slideForward
                                ? const Offset(1.0, 0.0)
                                : const Offset(-1.0, 0.0);
                            final outOffset = _slideForward
                                ? const Offset(-1.0, 0.0)
                                : const Offset(1.0, 0.0);

                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: isIncoming ? inOffset : outOffset,
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          layoutBuilder: (Widget? currentChild,
                              List<Widget> previousChildren) {
                            return Stack(
                              alignment: Alignment.topCenter,
                              children: <Widget>[
                                ...previousChildren,
                                if (currentChild != null) currentChild,
                              ],
                            );
                          },
                          child: SizedBox(
                            key: ValueKey<String>(dateKey),
                            width: double.infinity,
                            child: Card(
                              color: isDarkBg
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Theme.of(context).cardColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20.0, top: 16.0, bottom: 0.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                              width: 60,
                                              child: Text(l10n.adhan,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isDarkBg
                                                          ? Colors.white
                                                              .withValues(
                                                                  alpha: 0.7)
                                                          : Colors.grey[600]))),
                                          const SizedBox(width: 20),
                                          SizedBox(
                                              width: 60,
                                              child: Text(l10n.jamaat,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isDarkBg
                                                          ? Colors.white
                                                              .withValues(
                                                                  alpha: 0.7)
                                                          : Colors.grey[600]))),
                                        ],
                                      ),
                                    ),
                                    _buildPrayerTile(
                                        context,
                                        0,
                                        l10n.fajr,
                                        LucideIcons.moonStar,
                                        prayerData.fajr,
                                        prayerData.fajrJamaat),
                                    _buildPrayerTile(
                                        context,
                                        1,
                                        l10n.sunrise,
                                        LucideIcons.sunrise,
                                        prayerData.sunrise,
                                        null,
                                        isSunrise: true),
                                    _buildPrayerTile(
                                        context,
                                        2,
                                        l10n.duhr,
                                        LucideIcons.sun,
                                        prayerData.duhr,
                                        prayerData.duhrJamaat),
                                    _buildPrayerTile(
                                        context,
                                        3,
                                        l10n.asr,
                                        LucideIcons.cloudSun,
                                        prayerData.asr,
                                        prayerData.asrJamaat),
                                    _buildPrayerTile(
                                        context,
                                        4,
                                        l10n.maghrib,
                                        LucideIcons.sunset,
                                        prayerData.maghrib,
                                        prayerData.maghribJamaat),
                                    _buildPrayerTile(
                                        context,
                                        5,
                                        l10n.isha,
                                        LucideIcons.moon,
                                        prayerData.isha,
                                        prayerData.ishaJamaat),
                                    if (date.weekday == DateTime.friday)
                                      _buildPrayerTile(
                                          context,
                                          6,
                                          l10n.jumuah,
                                          Icons.mosque_outlined,
                                          null,
                                          prayerData.jumma,
                                          isJumma: true,
                                          jamaatTime2: prayerData.jumma2,
                                          jamaatTime3: prayerData.jumma3),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  useRootNavigator: true,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.8,
                                    child: MonthlyPrayerCalendar(
                                      mosallaId: provider.selectedMosallaId,
                                      monthYear: provider.date,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.table_chart_outlined),
                              label: Text(l10n.monthlyTable),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    isDarkBg ? Colors.white : Colors.teal[700],
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: isDarkBg
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : Colors.teal.withValues(alpha: 0.05),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => const EventsPage()),
                                );
                              },
                              icon: const Icon(Icons.event_outlined),
                              label: Text(l10n.events),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    isDarkBg ? Colors.white : Colors.teal[700],
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: isDarkBg
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : Colors.teal.withValues(alpha: 0.05),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
