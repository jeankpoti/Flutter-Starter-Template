import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../common_widgets/body_medium_text_widget.dart';
import '../../../common_widgets/icon_widget.dart';
import '../domain/models/collection.dart';
import 'firebase_collection_cubit.dart';
import 'solve_math_cubit.dart';

class ListTileWidget extends StatefulWidget {
  // final String? imageUrl, desc;
  final Collection collection;
  final bool isTrailingVisible;

  const ListTileWidget({
    super.key,
    // this.imageUrl,
    // this.desc,
    required this.collection,
    this.isTrailingVisible = true,
  });

  @override
  State<ListTileWidget> createState() => _ListTileWidgetState();
}

class _ListTileWidgetState extends State<ListTileWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Map<String, dynamic>> get choices => [
    // {'title': 'Edit', 'icon': const IconWidget(icon: Icons.edit)},
    {'title': 'Delete', 'icon': const IconWidget(icon: Icons.delete)},
  ];

  Future<void> showMyDialog(Collection collection) async {
    final firebaseAnimalCubit = context.read<FirebaseCollectionCubit>();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const BodyMediumTextWidget(
            text: 'Are you sure you want to delete this file?',
          ),
          actions: <Widget>[
            TextButton(
              child: const BodyMediumTextWidget(text: 'Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const BodyMediumTextWidget(text: 'Delete'),
              onPressed: () {
                // Run animation before actual deletion
                firebaseAnimalCubit.deleteCollection(collection);

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // void _animateAndDelete(
  //   Animal animal,
  //   FirebaseAnimalCubit firebaseAnimalCubit,
  // ) async {
  //   // Start the animation
  //   await _animationController.forward();
  //   // Delete the todo after animation completes
  //   firebaseAnimalCubit.deleteAnimal(animal);
  // }

  // void handleClick(String value, Animal animal) {
  //   switch (value) {
  //     case 'Delete':
  //       showMyDialog(animal);
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Leading image
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.collection.imageUrl ?? '',
                  fit: BoxFit.cover,
                  width: 100,
                  height: 120,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 20,
                  children: [
                    BodyMediumTextWidget(
                      text: widget.collection.description ?? '',
                      maxLine: 3,
                    ),
                    BodyMediumTextWidget(
                      text:
                          widget.collection.createdAt != null
                              ? DateFormat(
                                'MMMM dd, yyyy',
                              ).format(widget.collection.createdAt!)
                              : '',
                      maxLine: 1,
                    ),
                  ],
                ),
              ),
            ),

            // Optional trailing widget
            if (widget.isTrailingVisible)
              IconButton(
                onPressed: () {
                  showMyDialog(widget.collection);
                },
                icon: Icon(Icons.delete),
              ),
          ],
        ),
      ),
    );
  }
}
