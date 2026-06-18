import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/custom_container.dart';
import 'package:smedge/constants/numbers.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {

  int selectedTab = 0;
  final tabs = ["All", "Unread", "Actions"];
  final List<Map<String, dynamic>> notifications = [
    {"type": "Today"},
    {
      "title": "Welcome to smedge",
      "desc": "Your business finance journey starts here",
      "time": "2m ago",
      "color": Colors.blue
    },
    {
      "title": "Financing approved",
      "desc": "Your AED 250,000 application has been approved",
      "time": "38m ago",
      "color": Colors.green
    },
    {
      "title": "Upload pending documents",
      "desc": "Please upload VAT returns to continue processing",
      "time": "3h ago",
      "color": Colors.red
    },
    {"type": "Yesterday"},
    {
      "title": "Upcoming payment due",
      "desc": "AED 18,113 due on 15 May 2026",
      "time": "Yesterday, 4:21 pm",
      "color": Colors.orange
    },
    {
      "title": "New SME account",
      "desc": "Exploring banking solutions built for your business",
      "time": "Yesterday, 9:02 am",
      "color": Colors.blue
    },
    {"type": "Earlier"},
    {
      "title": "New login detected",
      "desc": "Your account was accessed from a new device",
      "time": "Mon, 21 Apr",
      "color": Colors.grey
    },
    {
      "title": "Complete your profile",
      "desc": "Unlock exclusive rewards and benefits",
      "time": "Sun, 20 Apr",
      "color": Colors.amber
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title:Text(
          'Notification',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ) ,
      ),
      body: Column(
        children: [
          Padding(
            padding:  EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: List.generate(tabs.length, (index) {
                  final selected = selectedTab == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedTab = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.blue.shade100
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tabs[index],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.blue.shade900
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.blue.shade900
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "3",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding:  EdgeInsets.symmetric(horizontal: Numbers.DOUBLE_NUMBER_16),
              itemCount: notifications.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = notifications[index];
                if (item.containsKey("type")) {
                  return Row(
                    children: [
                      Text(
                        item["type"],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      )
                    ],
                  );
                }
                return CustomContainer(
                  padding: Numbers.DOUBLE_NUMBER_12,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item["color"].withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.notifications,
                            color: item["color"], size: 18),
                      ),

                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["title"],
                              style:
                              const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item["desc"],
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item["time"],
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
