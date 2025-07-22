import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../common_widgets/app_bar_widget.dart';
import '../../../common_widgets/body_medium_text_widget.dart';
import '../../../common_widgets/loader_widget.dart';
import 'firebase_collection_cubit.dart';
import 'firebase_collection_state.dart';
import 'collections_details_page.dart';
import 'list_tile_widget.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    // Initial data fetch
    // Ensure Cubit is accessible. If provided above this widget, this is okay.
    // Use addPostFrameCallback to ensure build context is ready if cubit is provided by a parent that might rebuild.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Check if the widget is still in the tree
        context.read<FirebaseCollectionCubit>().getCollections();
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 20), () {
      if (!_scrollController.hasClients ||
          context.read<FirebaseCollectionCubit>().state.isLoadingMore) {
        return;
      }

      // Check if scrolled to near the bottom
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<FirebaseCollectionCubit>().loadMoreCollections();
      }
    });
  }

  // void _onScroll() {
  //   if (!_scrollController.hasClients ||
  //       context.read<FirebaseAnimalCubit>().state.isLoadingMore)
  //     return;

  //   // Check if scrolled to near the bottom
  //   if (_scrollController.position.pixels >=
  //       _scrollController.position.maxScrollExtent - 200) {
  //     // 200 is an offset
  //     context.read<FirebaseAnimalCubit>().loadMoreAnimals();
  //   }
  // }

  Future<void> _refreshData() async {
    // The Cubit's getAnimals method with isRefresh=true will handle resetting state.
    await context.read<FirebaseCollectionCubit>().getCollections(
      isRefresh: true,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'state.collections.isEmpty: ${context.read<FirebaseCollectionCubit>().state.collections.isEmpty}',
    );

    return Scaffold(
      appBar: AppBarWidget(title: 'Recent Problems'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: BlocConsumer<FirebaseCollectionCubit, FirebaseCollectionState>(
            listener: (context, state) {
              // Optional: Show snackbar for errors during "load more"
              if (state.isError &&
                  state.collections.isNotEmpty &&
                  !state.isLoading &&
                  !state.isLoadingMore) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Could not load more problems.'),
                    ),
                  );
              }
            },
            builder: (context, state) {
              // 1) Initial Loading (when animals list is empty)
              if (state.isLoading && state.collections.isEmpty) {
                return const Center(child: LoaderWidget());
              }

              // 2) Error during initial load (when animals list is empty)
              if (state.isError && state.collections.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const BodyMediumTextWidget(text: 'Something went wrong!'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed:
                            () => context
                                .read<FirebaseCollectionCubit>()
                                .getCollections(isRefresh: true),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              // 2) Error during load more
              if (state.isError && state.collections.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load more problems'),
                      ElevatedButton(
                        onPressed:
                            () =>
                                context
                                    .read<FirebaseCollectionCubit>()
                                    .loadMoreCollections(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // 3) No animals found (after initial load, list is empty, not loading)
              if (state.collections.isEmpty &&
                  !state.isLoading &&
                  !state.isLoadingMore) {
                return LayoutBuilder(
                  // Ensures scrollability for RefreshIndicator
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: const Center(
                          child: BodyMediumTextWidget(
                            text: 'No solved problems yet! Solve your first math problem to see it here.',
                          ),
                        ),
                      ),
                    );
                  },
                );
              }

              // 4) Show the animals list
              return ListView.builder(
                controller: _scrollController,
                physics:
                    const AlwaysScrollableScrollPhysics(), // Essential for RefreshIndicator
                itemCount:
                    state.collections.length + (state.hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.collections.length) {
                    // This is the last item - show loading indicator if hasMoreData and isLoadingMore
                    if (state.hasMoreData) {
                      return state.isLoadingMore
                          ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: LoaderWidget()),
                          )
                          : const SizedBox.shrink();
                    } else {
                      // Optionally show a "No more items" message
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No more animals to load',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      );
                    }
                  }

                  // Display your animal tile
                  final collection = state.collections[index];
                  return GestureDetector(
                    onTap:
                        () => PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: CollectionsDetailsPage(
                            collection: collection,
                          ),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        ),

                    child: ListTileWidget(
                      collection: collection,
                      isTrailingVisible: true, // Your existing prop
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
