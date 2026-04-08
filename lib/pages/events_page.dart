import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mosalla/l10n/generated/app_localizations.dart';
import '../providers/prayer_time_provider.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final events = context.watch<PrayerTimeProvider>().events;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcomingEvents = events.where((e) => !e.date.isBefore(today)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final pastEvents = events.where((e) => e.date.isBefore(today)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.events),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.upcomingEvents),
              Tab(text: l10n.pastEvents),
            ],
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          children: [
            _buildEventList(context, upcomingEvents, 'No upcoming events scheduled'),
            _buildEventList(context, pastEvents, 'No past events'),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(BuildContext context, List<dynamic> filteredEvents, String emptyMessage) {
    if (filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        final locale = Localizations.localeOf(context);
        final isJapanese = locale.languageCode == 'ja';
        
        final title = (isJapanese && event.japaneseTitle != null && event.japaneseTitle!.isNotEmpty)
            ? event.japaneseTitle!
            : event.title;
        final description = (isJapanese && event.japaneseDescription != null && event.japaneseDescription!.isNotEmpty)
            ? event.japaneseDescription!
            : event.description;

        String? timeRange;
        final localeCode = Localizations.localeOf(context).languageCode;
        if (event.startTime != null) {
          timeRange = DateFormat.Hm(localeCode).format(event.startTime!);
          if (event.endTime != null) {
            timeRange = '$timeRange - ${DateFormat.Hm(localeCode).format(event.endTime!)}';
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (event.imageUrl.isNotEmpty)
                Image.network(
                  event.imageUrl,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  ),
                )
              else
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal[700]!, Colors.teal[400]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.event, size: 50, color: Colors.white70),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                DateFormat.MMMd(Localizations.localeOf(context).languageCode).format(event.date),
                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (timeRange != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4, right: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      timeRange,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
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
