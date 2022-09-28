import 'package:eros_n/common/extension.dart';
import 'package:eros_n/common/global.dart';
import 'package:eros_n/component/models/index.dart';
import 'package:eros_n/component/widget/eros_cached_network_image.dart';
import 'package:eros_n/pages/gallery/gallery_provider.dart';
import 'package:eros_n/pages/nav/history/history_provider.dart';
import 'package:eros_n/pages/nav/index/index_provider.dart';
import 'package:eros_n/routes/routes.dart';
import 'package:eros_n/store/db/entity/gallery_history.dart';
import 'package:eros_n/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

class HistoryPage extends StatefulHookConsumerWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // ref.read(favoriteProvider.notifier).loadData();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      ref.read(indexProvider.notifier).hideNavigationBar();
    }
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      ref.read(indexProvider.notifier).showNavigationBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('History'),
      // ),
      body: Scrollbar(
        controller: scrollController,
        child: CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverAppBar(
              title: Text('History'),
              floating: true,
              pinned: true,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: SizedBox(height: 0),
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final historys = ref.watch(historyGallerysProvider);
                final historysGroupByDate = groupByDate(historys);
                // final historysGroupByDateKeys = historysGroupByDate.keys.toList();
                return MultiSliver(
                    children: historysGroupByDate.entries.map(
                  (e) {
                    final DateTime date = e.key;
                    // if date is today
                    final String dateStr = date.isToday()
                        ? 'Today'
                        : date.isYesterday()
                            ? 'Yesterday'
                            : date.toLocal().toString().split(' ')[0];
                    final historysInDate = e.value;
                    return MultiSliver(
                      pushPinnedChildren: true,
                      children: [
                        SliverPinnedHeader(
                          child: Container(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              dateStr,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final history = historysInDate[index];
                              return HistoryItem(history: history);
                            },
                            childCount: historysInDate.length,
                          ),
                        ),
                      ],
                    );
                  },
                ).toList());
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class HistoryItem extends HookConsumerWidget {
  const HistoryItem({
    Key? key,
    required this.history,
  }) : super(key: key);

  final GalleryHistory history;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        final gallery = Gallery(
          gid: '${history.gid}',
          url: history.url,
          imageKey: history.imageKey,
          title: history.title,
          secondTitle: history.secondTitle,
          thumbUrl: history.thumbUrl,
          thumbWidth: history.thumbWidth,
          thumbHeight: history.thumbHeight,
        );
        ref
            .read(galleryProvider('${history.gid}').notifier)
            .initFromGallery(gallery);
        erosRouter.push(GalleryRoute(gid: gallery.gid));
      },
      child: Container(
        height: 84,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: ErosCachedNetworkImage(
                    imageUrl: history.thumbUrl ?? '',
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  Text(
                    history.title ?? '',
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ),
            IconButton(
                onPressed: () {
                  ref.read(historyProvider.notifier).removeHistory(history.gid);
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                )),
          ],
        ),
      ),
    );
  }
}

Map<DateTime, List<GalleryHistory>> groupByDate(List<GalleryHistory> historys) {
  final Map<DateTime, List<GalleryHistory>> map = {};
  for (final history in historys) {
    final date = DateTime.fromMillisecondsSinceEpoch(history.lastReadTime ?? 0);
    final key = DateTime(date.year, date.month, date.day);
    if (map.containsKey(key)) {
      map[key]!.add(history);
    } else {
      map[key] = [history];
    }
  }
  return map;
}
