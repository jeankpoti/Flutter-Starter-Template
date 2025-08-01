// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../../../l10n/app_localizations.dart';
// import '../../../common_widgets/math_symbols_widget.dart';
// import '../../../common_widgets/text_widgets.dart';
// import '../data/services/study_plan_service.dart';
// import '../data/services/quiz_service.dart';
// import '../data/repository/study_material_repository.dart';
// import '../data/repository/study_plan_repository.dart';
// import '../domain/models/study_material.dart' as study;
// import '../domain/models/study_plan.dart';
// import '../domain/models/quiz.dart';
// import 'quiz_page.dart';
// import 'quiz_history_page.dart';

// class StudyPage extends StatefulWidget {
//   const StudyPage({super.key});

//   @override
//   State<StudyPage> createState() => _StudyPageState();
// }

// class _StudyPageState extends State<StudyPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final ImagePicker _picker = ImagePicker();
//   final StudyPlanService _studyPlanService = StudyPlanService();
//   final QuizService _quizService = QuizService();
//   final StudyMaterialRepository _materialRepository = StudyMaterialRepository();
//   final StudyPlanRepository _planRepository = StudyPlanRepository();

//   List<study.StudyMaterial> _studyMaterials = [];
//   List<StudyPlan> _studyPlans = [];
//   bool _isProcessing = false;
//   String? _processingPlanId;

//   // Material upload limits
//   static const int _maxImagesPerSelection = 5;

//   // Design system spacing constants
//   static const double _spacing4 = 16.0;
//   static const double _spacing6 = 24.0;
//   static const double _spacing8 = 32.0;

//   // Quiz button loading states
//   bool _isQuickQuizLoading = false;
//   bool _isPracticeTestLoading = false;
//   bool _isChallengeLoading = false;
//   bool _isAllMaterialsQuizLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _initializeServices();
//   }

//   Future<void> _initializeServices() async {
//     try {
//       await _studyPlanService.initialize();
//       await _quizService.initialize();

//       // Load persisted data
//       await _loadPersistedData();
//     } catch (e) {
//       debugPrint('Error initializing services: $e');
//     }
//   }

//   Future<void> _loadPersistedData() async {
//     try {
//       setState(() {
//         _isProcessing = true;
//       });

//       // Load study materials and plans in parallel
//       final futures = await Future.wait([
//         _materialRepository.getUserMaterials(),
//         _planRepository.getUserPlans(),
//       ]);

//       final materials = futures[0] as List<study.StudyMaterial>;
//       final plans = futures[1] as List<StudyPlan>;

//       setState(() {
//         _studyMaterials = materials;
//         _studyPlans = plans;
//         _isProcessing = false;
//       });

//       debugPrint(
//         'Loaded ${materials.length} materials and ${plans.length} plans from database',
//       );
//     } catch (e) {
//       setState(() {
//         _isProcessing = false;
//       });
//       debugPrint('Error loading persisted data: $e');

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               '${AppLocalizations.of(context)!.errorLoadingStudyData}: $e',
//               color: Theme.of(context).colorScheme.onErrorContainer,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
//       appBar: AppBar(
//         title: HeadlineSmallText(
//           AppLocalizations.of(context)!.studyMaterialsTitle,
//           fontWeight: FontWeight.w600,
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(
//               Icons.refresh_rounded,
//               color: Theme.of(context).colorScheme.onSurface,
//             ),
//             onPressed: _refreshData,
//             tooltip: AppLocalizations.of(context)!.refreshData,
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: CustomScrollView(
//           slivers: [
//             // Tab Section
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: _spacing4),
//                 child: _buildModernTabBar(),
//               ),
//             ),

//             // Content Section
//             SliverToBoxAdapter(
//               child: SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.7,
//                 child: Padding(
//                   padding: const EdgeInsets.all(_spacing4),
//                   child: TabBarView(
//                     controller: _tabController,
//                     children: [_buildUploadTab(), _buildMaterialsTab()],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildModernTabBar() {
//     return Container(
//       margin: const EdgeInsets.only(bottom: _spacing6),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(16.0),
//         boxShadow: [
//           BoxShadow(
//             color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
//             offset: const Offset(0, 4),
//             blurRadius: 12.0,
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: TabBar(
//         controller: _tabController,
//         indicator: BoxDecoration(
//           borderRadius: BorderRadius.circular(16.0),
//           color: Theme.of(context).colorScheme.secondaryContainer,
//         ),
//         labelColor: Theme.of(context).colorScheme.onSecondaryContainer,
//         unselectedLabelColor: Theme.of(
//           context,
//         ).colorScheme.onSurface.withValues(alpha: 0.6),
//         indicatorSize: TabBarIndicatorSize.tab,
//         dividerColor: Colors.transparent,
//         labelStyle: Theme.of(
//           context,
//         ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
//         tabs: [
//           Tab(
//             icon: const Icon(Icons.upload_file_outlined),
//             text: AppLocalizations.of(context)!.uploadTab,
//             height: 60,
//           ),
//           Tab(
//             icon: const Icon(Icons.library_books_outlined),
//             text: AppLocalizations.of(context)!.myMaterialsTab,
//             height: 60,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUploadTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(_spacing4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.all(_spacing4),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Theme.of(
//                     context,
//                   ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
//                   Theme.of(
//                     context,
//                   ).colorScheme.tertiaryContainer.withValues(alpha: 0.2),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.auto_awesome,
//                       color: Theme.of(context).colorScheme.secondary,
//                       size: 28,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: HeadlineSmallText(
//                         AppLocalizations.of(context)!.uploadYourStudyMaterial,
//                         fontWeight: FontWeight.bold,
//                         color: Theme.of(context).colorScheme.onSurface,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 BodyMediumText(
//                   AppLocalizations.of(context)!.uploadDescription,
//                   color: Theme.of(
//                     context,
//                   ).colorScheme.onSurface.withValues(alpha: 0.8),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: _spacing8),

//           // Loading Progress Bar
//           if (_isProcessing) ...[
//             _buildProcessingIndicator(),
//             const SizedBox(height: _spacing6),
//           ],

//           // Upload Options
//           _buildUploadOption(
//             icon: Icons.camera_alt,
//             title: AppLocalizations.of(context)!.takePhoto,
//             subtitle: AppLocalizations.of(context)!.takePhotoSubtitle,
//             onTap: () => _handlePhotoUpload(),
//           ),

//           const SizedBox(height: 16),

//           _buildUploadOption(
//             icon: Icons.photo_library,
//             title: AppLocalizations.of(context)!.uploadFromGallery,
//             subtitle:
//                 '${AppLocalizations.of(context)!.uploadFromGallerySubtitle} (Max $_maxImagesPerSelection images per selection)',
//             onTap: () => _handleGalleryUpload(),
//           ),

//           const SizedBox(height: 16),

//           _buildUploadOption(
//             icon: Icons.edit_note,
//             title: AppLocalizations.of(context)!.typeMaterial,
//             subtitle: AppLocalizations.of(context)!.typeMaterialSubtitle,
//             onTap: () => _handleTextInput(),
//           ),

//           const SizedBox(height: _spacing8),

//           // Recent Uploads Section
//           _buildRecentUploadsSection(),
//         ],
//       ),
//     );
//   }

//   Widget _buildUploadOption({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     final isDisabled = _isProcessing;

//     return Container(
//       decoration: BoxDecoration(
//         color:
//             isDisabled
//                 ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
//                 : Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color:
//               isDisabled
//                   ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)
//                   : Theme.of(
//                     context,
//                   ).colorScheme.outline.withValues(alpha: 0.2),
//         ),
//       ),
//       child: InkWell(
//         onTap: isDisabled ? null : onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Theme.of(
//                     context,
//                   ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(
//                   icon,
//                   color:
//                       isDisabled
//                           ? Theme.of(
//                             context,
//                           ).colorScheme.secondary.withValues(alpha: 0.4)
//                           : Theme.of(context).colorScheme.secondary,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TitleMediumText(
//                       title,
//                       fontWeight: FontWeight.w600,
//                       color:
//                           isDisabled
//                               ? Theme.of(
//                                 context,
//                               ).colorScheme.onSurface.withValues(alpha: 0.4)
//                               : Theme.of(context).colorScheme.onSurface,
//                     ),
//                     const SizedBox(height: 4),
//                     BodySmallText(
//                       subtitle,
//                       color:
//                           isDisabled
//                               ? Theme.of(
//                                 context,
//                               ).colorScheme.onSurface.withValues(alpha: 0.3)
//                               : Theme.of(
//                                 context,
//                               ).colorScheme.onSurface.withValues(alpha: 0.7),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios,
//                 color:
//                     isDisabled
//                         ? Theme.of(
//                           context,
//                         ).colorScheme.onSurface.withValues(alpha: 0.2)
//                         : Theme.of(
//                           context,
//                         ).colorScheme.onSurface.withValues(alpha: 0.4),
//                 size: 16,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentUploadsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TitleMediumText(
//           AppLocalizations.of(context)!.recentUploads,
//           fontWeight: FontWeight.bold,
//           color: Theme.of(context).colorScheme.onSurface,
//         ),
//         const SizedBox(height: 16),

//         if (_studyMaterials.isEmpty)
//           Container(
//             padding: const EdgeInsets.all(_spacing6),
//             decoration: BoxDecoration(
//               color: Theme.of(
//                 context,
//               ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               children: [
//                 Icon(
//                   Icons.upload_file,
//                   size: 48,
//                   color: Theme.of(
//                     context,
//                   ).colorScheme.onSurface.withValues(alpha: 0.4),
//                 ),
//                 const SizedBox(height: 12),
//                 BodyMediumText(
//                   AppLocalizations.of(context)!.noMaterialsUploaded,
//                   color: Theme.of(
//                     context,
//                   ).colorScheme.onSurface.withValues(alpha: 0.6),
//                 ),
//                 const SizedBox(height: 8),
//                 BodySmallText(
//                   AppLocalizations.of(context)!.uploadFirstMaterial,
//                   color: Theme.of(
//                     context,
//                   ).colorScheme.onSurface.withValues(alpha: 0.5),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           )
//         else
//           SizedBox(
//             height: 120,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: _studyMaterials.length,
//               itemBuilder: (context, index) {
//                 final material = _studyMaterials[index];
//                 return Container(
//                   width: 140,
//                   margin: const EdgeInsets.only(right: 12),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.surface,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.outline.withValues(alpha: 0.3),
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(
//                               material.type == study.MaterialType.image
//                                   ? Icons.image
//                                   : Icons.text_snippet,
//                               color: Theme.of(context).colorScheme.secondary,
//                               size: 20,
//                             ),
//                             const Spacer(),
//                             Container(
//                               padding: const EdgeInsets.all(2),
//                               decoration: BoxDecoration(
//                                 color:
//                                     material.status ==
//                                             study.MaterialStatus.completed
//                                         ? Theme.of(
//                                           context,
//                                         ).colorScheme.secondary
//                                         : Theme.of(context).colorScheme.outline,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: Icon(
//                                 material.status ==
//                                         study.MaterialStatus.completed
//                                     ? Icons.check
//                                     : Icons.access_time,
//                                 color:
//                                     Theme.of(context).colorScheme.onSecondary,
//                                 size: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               BodySmallText(
//                                 material.title,
//                                 fontWeight: FontWeight.w600,
//                                 color: Theme.of(context).colorScheme.onSurface,
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               const SizedBox(height: 4),
//                               LabelSmallText(
//                                 '${material.extractedTopics.length} ${AppLocalizations.of(context)!.topics}',
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.onSurface.withValues(alpha: 0.6),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildMaterialsTab() {
//     return RefreshIndicator(
//       onRefresh: _refreshData,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(_spacing4),
//         physics: const AlwaysScrollableScrollPhysics(),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Study Plans Section
//             if (_studyPlans.isNotEmpty) ...[
//               _buildStudyPlansSection(),
//               const SizedBox(height: _spacing8),
//             ],

//             // Quiz Section
//             if (_studyMaterials.isNotEmpty) ...[
//               _buildQuizSection(),
//               const SizedBox(height: _spacing8),
//             ],

//             // Materials Section
//             HeadlineSmallText(
//               AppLocalizations.of(context)!.myStudyMaterials,
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.onSurface,
//             ),
//             const SizedBox(height: 16),

//             if (_studyMaterials.isEmpty)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(_spacing8),
//                 decoration: BoxDecoration(
//                   color: Theme.of(
//                     context,
//                   ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.library_books,
//                       size: 64,
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.onSurface.withValues(alpha: 0.4),
//                     ),
//                     const SizedBox(height: 16),
//                     TitleMediumText(
//                       AppLocalizations.of(context)!.noStudyMaterials,
//                       fontWeight: FontWeight.w600,
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.onSurface.withValues(alpha: 0.6),
//                     ),
//                     const SizedBox(height: 8),
//                     BodyMediumText(
//                       AppLocalizations.of(context)!.noStudyMaterialsDescription,
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.onSurface.withValues(alpha: 0.5),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               )
//             else
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: _studyMaterials.length,
//                 itemBuilder: (context, index) {
//                   final material = _studyMaterials[index];
//                   return _buildMaterialCard(material);
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStudyPlansSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         HeadlineSmallText(
//           AppLocalizations.of(context)!.myStudyPlans,
//           fontWeight: FontWeight.bold,
//           color: Theme.of(context).colorScheme.onSurface,
//         ),
//         const SizedBox(height: 16),

//         // Horizontal scrollable plans
//         SizedBox(
//           height: 240,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: _studyPlans.length,
//             itemBuilder: (context, index) {
//               return _buildStudyPlanCard(_studyPlans[index]);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStudyPlanCard(StudyPlan plan) {
//     return Container(
//       width: 280,
//       height: 250, // Increased height for additional buttons
//       margin: const EdgeInsets.only(right: 16),
//       child: Card(
//         elevation: 2,
//         child: InkWell(
//           onTap: () => _showStudyPlanTopics(plan),
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Theme.of(
//                     context,
//                   ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
//                   Theme.of(
//                     context,
//                   ).colorScheme.tertiaryContainer.withValues(alpha: 0.2),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.auto_awesome,
//                       color: Theme.of(context).colorScheme.secondary,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: TitleMediumText(
//                         plan.title,
//                         fontWeight: FontWeight.bold,
//                         color: Theme.of(context).colorScheme.onSurface,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     PopupMenuButton<String>(
//                       icon: Icon(
//                         Icons.more_vert,
//                         color: Theme.of(
//                           context,
//                         ).colorScheme.onSurface.withValues(alpha: 0.6),
//                         size: 20,
//                       ),
//                       onSelected: (value) {
//                         if (value == 'delete') {
//                           _deletePlan(plan.id);
//                         }
//                       },
//                       itemBuilder:
//                           (context) => [
//                             PopupMenuItem(
//                               value: 'delete',
//                               child: LabelLargeText(
//                                 AppLocalizations.of(context)!.deletePlan,
//                               ),
//                             ),
//                           ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 6),

//                 BodySmallText(
//                   plan.description,
//                   color: Theme.of(
//                     context,
//                   ).colorScheme.onSurface.withValues(alpha: 0.7),
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 12),

//                 // Progress indicator (clickable)
//                 InkWell(
//                   onTap: () => _showStudyPlanTopics(plan),
//                   borderRadius: BorderRadius.circular(4),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: LinearProgressIndicator(
//                             value: plan.calculateProgress() / 100,
//                             backgroundColor: Theme.of(
//                               context,
//                             ).colorScheme.outline.withValues(alpha: 0.3),
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               Theme.of(context).colorScheme.secondary,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         LabelSmallText(
//                           '${plan.calculateProgress().toStringAsFixed(0)}%',
//                           fontWeight: FontWeight.w600,
//                           color: Theme.of(context).colorScheme.secondary,
//                         ),
//                         const SizedBox(width: 4),
//                         Icon(
//                           Icons.arrow_forward_ios,
//                           size: 12,
//                           color: Theme.of(context).colorScheme.secondary,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 // Plan stats
//                 Row(
//                   children: [
//                     Flexible(
//                       child: _buildStatChip(
//                         icon: Icons.list_alt,
//                         label:
//                             '${plan.topics.length} ${AppLocalizations.of(context)!.topics}',
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Flexible(
//                       child: _buildStatChip(
//                         icon: Icons.schedule,
//                         label: '${plan.totalEstimatedHours}h',
//                       ),
//                     ),
//                   ],
//                 ),

//                 const Spacer(),

//                 // Action buttons row
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextButton.icon(
//                         onPressed: () => _showStudyPlanTopics(plan),
//                         icon: const Icon(Icons.list, size: 16),
//                         label: LabelMediumText(
//                           AppLocalizations.of(context)!.viewTopics,
//                           color: Theme.of(context).colorScheme.onSurface,
//                         ),
//                         style: TextButton.styleFrom(
//                           foregroundColor:
//                               Theme.of(context).colorScheme.secondary,
//                           padding: const EdgeInsets.symmetric(vertical: 6),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed:
//                             _processingPlanId == plan.id
//                                 ? null
//                                 : () => _startQuizFromPlan(plan),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor:
//                               _processingPlanId == plan.id
//                                   ? Theme.of(
//                                     context,
//                                   ).colorScheme.secondary.withValues(alpha: 0.6)
//                                   : Theme.of(context).colorScheme.secondary,
//                           foregroundColor:
//                               Theme.of(context).colorScheme.onSecondary,
//                           padding: const EdgeInsets.symmetric(vertical: 6),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child:
//                             _processingPlanId == plan.id
//                                 ? Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     SizedBox(
//                                       width: 10,
//                                       height: 10,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         valueColor:
//                                             AlwaysStoppedAnimation<Color>(
//                                               Theme.of(
//                                                 context,
//                                               ).colorScheme.onSecondary,
//                                             ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 6),
//                                     LabelSmallText(
//                                       AppLocalizations.of(context)!.loading,
//                                     ),
//                                   ],
//                                 )
//                                 : LabelMediumText(
//                                   AppLocalizations.of(context)!.takeQuiz,
//                                 ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProcessingIndicator() {
//     return Container(
//       padding: const EdgeInsets.all(_spacing4),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2.5,
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     Theme.of(context).colorScheme.secondary,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TitleMediumText(
//                       AppLocalizations.of(context)!.processingYourMaterial,
//                       fontWeight: FontWeight.w600,
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//                     const SizedBox(height: 4),
//                     BodySmallText(
//                       AppLocalizations.of(context)!.processingDescription,
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.onSurface.withValues(alpha: 0.7),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // Progress bar
//           LinearProgressIndicator(
//             backgroundColor: Theme.of(
//               context,
//             ).colorScheme.outline.withValues(alpha: 0.2),
//             valueColor: AlwaysStoppedAnimation<Color>(
//               Theme.of(context).colorScheme.secondary,
//             ),
//           ),

//           const SizedBox(height: 12),

//           // Processing steps
//           Row(
//             children: [
//               _buildProcessingStep(
//                 '📷',
//                 AppLocalizations.of(context)!.uploadStep,
//                 true,
//               ),
//               _buildProcessingStep(
//                 '🔍',
//                 AppLocalizations.of(context)!.analyzeStep,
//                 true,
//               ),
//               _buildProcessingStep(
//                 '📚',
//                 AppLocalizations.of(context)!.generatePlan,
//                 false,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProcessingStep(String emoji, String label, bool isCompleted) {
//     return Expanded(
//       child: Column(
//         children: [
//           Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               color:
//                   isCompleted
//                       ? Theme.of(
//                         context,
//                       ).colorScheme.secondary.withValues(alpha: 0.1)
//                       : Theme.of(
//                         context,
//                       ).colorScheme.outline.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color:
//                     isCompleted
//                         ? Theme.of(context).colorScheme.secondary
//                         : Theme.of(
//                           context,
//                         ).colorScheme.outline.withValues(alpha: 0.3),
//                 width: 1,
//               ),
//             ),
//             child: Center(
//               child:
//                   isCompleted
//                       ? Icon(
//                         Icons.check,
//                         size: 16,
//                         color: Theme.of(context).colorScheme.secondary,
//                       )
//                       : LabelSmallText(emoji),
//             ),
//           ),
//           const SizedBox(height: 4),
//           LabelSmallText(
//             label,
//             color:
//                 isCompleted
//                     ? Theme.of(context).colorScheme.secondary
//                     : Theme.of(
//                       context,
//                     ).colorScheme.onSurface.withValues(alpha: 0.6),
//             fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuizSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: HeadlineSmallText(
//                 AppLocalizations.of(context)!.practiceQuizzes,
//                 fontWeight: FontWeight.bold,
//                 color: Theme.of(context).colorScheme.onSurface,
//               ),
//             ),
//             TextButton.icon(
//               onPressed: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => const QuizHistoryPage(),
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.history),
//               label: LabelLargeText(AppLocalizations.of(context)!.history),
//               style: TextButton.styleFrom(
//                 foregroundColor: Theme.of(context).colorScheme.secondary,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),

//         Container(
//           padding: const EdgeInsets.all(_spacing4),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Theme.of(
//                   context,
//                 ).colorScheme.primaryContainer.withValues(alpha: 0.3),
//                 Theme.of(
//                   context,
//                 ).colorScheme.secondaryContainer.withValues(alpha: 0.2),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     Icons.quiz,
//                     color: Theme.of(context).colorScheme.secondary,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: TitleLargeText(
//                       AppLocalizations.of(context)!.testYourKnowledge,
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               BodyMediumText(
//                 AppLocalizations.of(context)!.testKnowledgeDescription,
//                 color: Theme.of(
//                   context,
//                 ).colorScheme.onSurface.withValues(alpha: 0.8),
//               ),
//               const SizedBox(height: 20),

//               // Quiz options
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildQuizOptionButton(
//                       icon: Icons.flash_on,
//                       title: AppLocalizations.of(context)!.quickQuiz,
//                       subtitle: AppLocalizations.of(context)!.quickQuizSubtitle,
//                       difficulty: QuizDifficulty.easy,
//                       questionCount: 5,
//                       timeLimit: 10,
//                       isLoading: _isQuickQuizLoading,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildQuizOptionButton(
//                       icon: Icons.school,
//                       title: AppLocalizations.of(context)!.practiceTest,
//                       subtitle:
//                           AppLocalizations.of(context)!.practiceTestSubtitle,
//                       difficulty: QuizDifficulty.medium,
//                       questionCount: 10,
//                       timeLimit: 20,
//                       isLoading: _isPracticeTestLoading,
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               // Challenge quiz (only if study plans exist)
//               if (_studyPlans.isNotEmpty)
//                 SizedBox(
//                   width: double.infinity,
//                   child: _buildQuizOptionButton(
//                     icon: Icons.emoji_events,
//                     title: AppLocalizations.of(context)!.challengeMode,
//                     subtitle:
//                         AppLocalizations.of(context)!.challengeModeSubtitle,
//                     difficulty: QuizDifficulty.hard,
//                     questionCount: 15,
//                     timeLimit: 30,
//                     isFullWidth: true,
//                     isLoading: _isChallengeLoading,
//                   ),
//                 ),

//               const SizedBox(height: 12),

//               // Generate quiz with all materials button (only if materials exist)
//               if (_studyMaterials.isNotEmpty)
//                 SizedBox(
//                   width: double.infinity,
//                   child: _buildAllMaterialsQuizButton(),
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQuizOptionButton({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required QuizDifficulty difficulty,
//     required int questionCount,
//     required int timeLimit,
//     bool isFullWidth = false,
//     bool isLoading = false,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
//         ),
//       ),
//       child: InkWell(
//         onTap:
//             isLoading
//                 ? null
//                 : () => _generateAndStartQuiz(
//                   difficulty: difficulty,
//                   questionCount: questionCount,
//                   timeLimit: timeLimit,
//                 ),
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child:
//               isFullWidth
//                   ? Row(
//                     children: [
//                       isLoading
//                           ? SizedBox(
//                             width: 24,
//                             height: 24,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 Theme.of(context).colorScheme.secondary,
//                               ),
//                             ),
//                           )
//                           : Icon(
//                             icon,
//                             color: Theme.of(context).colorScheme.secondary,
//                             size: 24,
//                           ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             TitleMediumText(
//                               title,
//                               fontWeight: FontWeight.w600,
//                               color: Theme.of(context).colorScheme.onSurface,
//                             ),
//                             BodySmallText(
//                               subtitle,
//                               color: Theme.of(
//                                 context,
//                               ).colorScheme.onSurface.withValues(alpha: 0.7),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Icon(
//                         Icons.arrow_forward_ios,
//                         color: Theme.of(
//                           context,
//                         ).colorScheme.onSurface.withValues(alpha: 0.4),
//                         size: 16,
//                       ),
//                     ],
//                   )
//                   : Column(
//                     children: [
//                       isLoading
//                           ? SizedBox(
//                             width: 32,
//                             height: 32,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 Theme.of(context).colorScheme.secondary,
//                               ),
//                             ),
//                           )
//                           : Icon(
//                             icon,
//                             color: Theme.of(context).colorScheme.secondary,
//                             size: 32,
//                           ),
//                       const SizedBox(height: 8),
//                       TitleSmallText(
//                         title,
//                         fontWeight: FontWeight.w600,
//                         color: Theme.of(context).colorScheme.onSurface,
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 4),
//                       LabelSmallText(
//                         subtitle,
//                         color: Theme.of(
//                           context,
//                         ).colorScheme.onSurface.withValues(alpha: 0.7),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatChip({required IconData icon, required String label}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
//           const SizedBox(width: 6),
//           LabelSmallText(
//             label,
//             fontWeight: FontWeight.w600,
//             color: Theme.of(context).colorScheme.onSurface,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAllMaterialsQuizButton() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
//         ),
//       ),
//       child: InkWell(
//         onTap:
//             _isAllMaterialsQuizLoading ? null : _generateQuizFromAllMaterials,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               _isAllMaterialsQuizLoading
//                   ? SizedBox(
//                     width: 24,
//                     height: 24,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         Theme.of(context).colorScheme.secondary,
//                       ),
//                     ),
//                   )
//                   : Icon(
//                     Icons.quiz_outlined,
//                     color: Theme.of(context).colorScheme.secondary,
//                     size: 24,
//                   ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TitleMediumText(
//                       AppLocalizations.of(
//                         context,
//                       )!.generateQuizWithAllMaterials,
//                       fontWeight: FontWeight.w600,
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//                     BodySmallText(
//                       AppLocalizations.of(context)!.allMaterialsQuizDescription,
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.onSurface.withValues(alpha: 0.7),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios,
//                 color: Theme.of(
//                   context,
//                 ).colorScheme.onSurface.withValues(alpha: 0.4),
//                 size: 16,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMaterialCard(study.StudyMaterial material) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Theme.of(
//                     context,
//                   ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   material.type == study.MaterialType.image
//                       ? Icons.image
//                       : Icons.text_snippet,
//                   color: Theme.of(context).colorScheme.secondary,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TitleMediumText(
//                       material.title,
//                       fontWeight: FontWeight.w600,
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//                     BodySmallText(
//                       material.difficultyLevel,
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.onSurface.withValues(alpha: 0.6),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color:
//                       material.status == study.MaterialStatus.completed
//                           ? Theme.of(context).colorScheme.secondary
//                           : Theme.of(context).colorScheme.outline,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   material.status == study.MaterialStatus.completed
//                       ? Icons.check
//                       : Icons.access_time,
//                   color: Theme.of(context).colorScheme.onSecondary,
//                   size: 16,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Upload functionality methods
//   Future<void> _handlePhotoUpload() async {
//     try {
//       // Check camera permission
//       if (Platform.isAndroid) {
//         final cameraStatus = await Permission.camera.request();
//         if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
//           _showPermissionDialog(AppLocalizations.of(context)!.camera);
//           return;
//         }
//       }

//       final XFile? photo = await _picker.pickImage(
//         source: ImageSource.camera,
//         maxWidth: 2400,
//         maxHeight: 2400,
//         imageQuality: 85,
//       );

//       if (photo != null) {
//         final File imageFile = File(photo.path);

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: BodyMediumText(
//                 AppLocalizations.of(context)!.materialCaptured,
//                 color: Theme.of(context).colorScheme.onSecondary,
//               ),
//               backgroundColor: Theme.of(context).colorScheme.secondary,
//               duration: const Duration(seconds: 2),
//             ),
//           );
//         }

//         await _processUploadedMaterial(imageFile, study.MaterialType.image);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(context)!.errorCapturingPhoto(e.toString()),
//               color: Theme.of(context).colorScheme.error,
//             ),
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _handleGalleryUpload() async {
//     try {
//       // Check photo permission
//       if (Platform.isAndroid) {
//         final photosStatus = await Permission.photos.request();
//         if (photosStatus.isDenied || photosStatus.isPermanentlyDenied) {
//           _showPermissionDialog(AppLocalizations.of(context)!.photoLibrary);
//           return;
//         }
//       }

//       final List<XFile> images = await _picker.pickMultiImage(
//         maxWidth: 2400,
//         maxHeight: 2400,
//         imageQuality: 85,
//         limit: _maxImagesPerSelection,
//       );

//       if (images.isNotEmpty) {
//         // Limit selection to maximum 5 images
//         final imagesToProcess = images.take(_maxImagesPerSelection).toList();

//         // Show feedback about selection limit if user selected more than 5
//         if (images.length > _maxImagesPerSelection) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: BodyMediumText(
//                   'You selected ${images.length} images, but only $_maxImagesPerSelection can be processed per selection. The first $_maxImagesPerSelection images will be uploaded.',
//                   color: Theme.of(context).colorScheme.onErrorContainer,
//                 ),
//                 backgroundColor: Theme.of(context).colorScheme.errorContainer,
//                 duration: const Duration(seconds: 5),
//               ),
//             );
//           }
//         }

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: BodyMediumText(
//                 AppLocalizations.of(
//                   context,
//                 )!.materialsUploaded(imagesToProcess.length),
//                 color: Theme.of(context).colorScheme.onSecondary,
//               ),
//               backgroundColor: Theme.of(context).colorScheme.secondary,
//               duration: const Duration(seconds: 2),
//             ),
//           );
//         }

//         for (final xFile in imagesToProcess) {
//           final imageFile = File(xFile.path);
//           await _processUploadedMaterial(imageFile, study.MaterialType.image);
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(
//                 context,
//               )!.errorUploadingFromGallery(e.toString()),
//               color: Theme.of(context).colorScheme.onError,
//             ),
//           ),
//         );
//       }
//     }
//   }

//   void _handleTextInput() {
//     showDialog(context: context, builder: (context) => _buildTextInputDialog());
//   }

//   Future<void> _processUploadedMaterial(
//     File? imageFile,
//     study.MaterialType type, {
//     String? textContent,
//   }) async {
//     setState(() {
//       _isProcessing = true;
//     });

//     try {
//       final materialId = DateTime.now().millisecondsSinceEpoch.toString();
//       final title =
//           type == study.MaterialType.image
//               ? AppLocalizations.of(
//                 context,
//               )!.studyMaterialTitle(_studyMaterials.length + 1)
//               : AppLocalizations.of(
//                 context,
//               )!.textMaterialTitle(_studyMaterials.length + 1);

//       // Analyze the material
//       final studyMaterial = await _studyPlanService.analyzeMaterial(
//         materialId: materialId,
//         type: type,
//         content: textContent,
//         imageFile: imageFile,
//         title: title,
//       );

//       // Handle image upload to Firebase Storage if needed
//       study.StudyMaterial finalMaterial = studyMaterial;
//       if (imageFile != null && type == study.MaterialType.image) {
//         try {
//           final downloadUrl = await _materialRepository.uploadImage(
//             imageFile,
//             materialId,
//           );
//           finalMaterial = studyMaterial.copyWith(
//             firebaseStoragePath: downloadUrl,
//           );
//         } catch (e) {
//           debugPrint('Warning: Could not upload image to storage: $e');
//           // Continue without Firebase Storage URL
//         }
//       }

//       // Save material to database
//       await _materialRepository.saveMaterial(finalMaterial);

//       setState(() {
//         _studyMaterials.add(finalMaterial);
//         _isProcessing = false;
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(context)!.materialAnalyzedSuccess,
//               color: Theme.of(context).colorScheme.onSecondary,
//             ),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }

//       // Generate individual study plan for this material
//       await _generateIndividualStudyPlan(finalMaterial);
//     } catch (e) {
//       setState(() {
//         _isProcessing = false;
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(
//                 context,
//               )!.errorProcessingMaterial(e.toString()),
//               color: Theme.of(context).colorScheme.onError,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     }
//   }

//   void _showPermissionDialog(String permissionType) {
//     showDialog(
//       context: context,
//       builder:
//           (ctx) => AlertDialog(
//             title: TitleLargeText(
//               AppLocalizations.of(
//                 context,
//               )!.permissionRequiredTitle(permissionType),
//             ),
//             content: BodyMediumText(
//               AppLocalizations.of(
//                 context,
//               )!.permissionRequiredMessage(permissionType),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(ctx).pop(),
//                 child: LabelLargeText(AppLocalizations.of(context)!.cancel),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(ctx).pop();
//                   openAppSettings();
//                 },
//                 child: LabelLargeText(
//                   AppLocalizations.of(context)!.openSettings,
//                 ),
//               ),
//             ],
//           ),
//     );
//   }

//   Widget _buildTextInputDialog() {
//     final TextEditingController textController = TextEditingController();

//     return AlertDialog(
//       title: TitleLargeText(AppLocalizations.of(context)!.addStudyMaterial),
//       content: SizedBox(
//         width: double.maxFinite,
//         height: 500, // Fixed height to prevent overflow
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               BodyMediumText(
//                 AppLocalizations.of(context)!.enterStudyMaterialText,
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: textController,
//                 maxLines: 6, // Reduced to make room for keyboard
//                 decoration: InputDecoration(
//                   hintText: AppLocalizations.of(context)!.pasteOrTypeHint,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   alignLabelWithHint: true,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Math Symbols Widget (exactly like homepage)
//               MathSymbolsWidget(controller: textController),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: LabelLargeText(AppLocalizations.of(context)!.cancel),
//         ),
//         ElevatedButton(
//           onPressed: () async {
//             if (textController.text.trim().isNotEmpty) {
//               Navigator.of(context).pop();

//               // Process the text input
//               await _processTextMaterial(textController.text.trim());
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Theme.of(context).colorScheme.secondary,
//           ),
//           child: LabelLargeText(
//             AppLocalizations.of(context)!.addMaterial,
//             color: Theme.of(context).colorScheme.onSecondary,
//           ),
//         ),
//       ],
//     );
//   }

//   Future<void> _processTextMaterial(String text) async {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: BodyMediumText(
//             AppLocalizations.of(context)!.processingTextMaterial,
//             color: Theme.of(context).colorScheme.onSecondary,
//           ),
//           backgroundColor: Theme.of(context).colorScheme.secondary,
//         ),
//       );
//     }

//     await _processUploadedMaterial(
//       null,
//       study.MaterialType.text,
//       textContent: text,
//     );
//   }

//   Future<void> _generateIndividualStudyPlan(
//     study.StudyMaterial material,
//   ) async {
//     try {
//       setState(() {
//         _isProcessing = true;
//       });

//       final studyPlan = await _studyPlanService.generateStudyPlan(
//         materials: [material], // Only this material
//         customTitle: "Plan: ${material.title}",
//       );

//       // Save study plan to database
//       await _planRepository.savePlan(studyPlan);

//       setState(() {
//         _studyPlans.add(studyPlan);
//         _isProcessing = false;
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(context)!.studyPlanCreated(studyPlan.title),
//               color: Theme.of(context).colorScheme.onSecondary,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.secondary,
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isProcessing = false;
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(
//                 context,
//               )!.errorGeneratingStudyPlan(e.toString()),
//               color: Theme.of(context).colorScheme.onError,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _generateAndStartQuiz({
//     required QuizDifficulty difficulty,
//     required int questionCount,
//     required int timeLimit,
//   }) async {
//     // Set the appropriate loading state based on difficulty
//     setState(() {
//       switch (difficulty) {
//         case QuizDifficulty.easy:
//           _isQuickQuizLoading = true;
//           break;
//         case QuizDifficulty.medium:
//           _isPracticeTestLoading = true;
//           break;
//         case QuizDifficulty.hard:
//           _isChallengeLoading = true;
//           break;
//       }
//     });

//     // Check if we have study plans and need to show selection dialog
//     if (_studyPlans.length > 1) {
//       final selectedPlan = await _showStudyPlanSelectionDialog();
//       if (selectedPlan == null) {
//         // User cancelled selection
//         setState(() {
//           _resetQuizLoadingStates(difficulty);
//         });
//         return;
//       }

//       await _generateQuizFromPlan(
//         selectedPlan,
//         difficulty: difficulty,
//         questionCount: questionCount,
//         timeLimit: timeLimit,
//       );
//       return;
//     }

//     if (_studyMaterials.isEmpty && _studyPlans.isEmpty) {
//       setState(() {
//         _resetQuizLoadingStates(difficulty);
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(context)!.noStudyMaterialsForQuiz,
//               color: Theme.of(context).colorScheme.onSecondary,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.secondary,
//           ),
//         );
//       }
//       return;
//     }

//     setState(() {
//       _isProcessing = true;
//     });

//     try {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(
//                 context,
//               )!.generatingQuizWithCount(questionCount),
//               color: Theme.of(context).colorScheme.onSecondary,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.secondary,
//           ),
//         );
//       }

//       Quiz quiz;

//       // If we have exactly one study plan, use it
//       if (_studyPlans.length == 1) {
//         quiz = await _quizService.generateQuizFromStudyPlan(
//           studyPlan: _studyPlans.first,
//           difficulty: difficulty,
//           questionCount: questionCount,
//           timeLimit: timeLimit,
//         );
//       } else {
//         // Generate from study materials
//         quiz = await _quizService.generateQuizFromMaterials(
//           materials: _studyMaterials,
//           difficulty: difficulty,
//           questionCount: questionCount,
//           timeLimit: timeLimit,
//         );
//       }

//       setState(() {
//         _isProcessing = false;
//         _resetQuizLoadingStates(difficulty);
//       });

//       if (mounted) {
//         // Navigate to quiz page
//         Navigator.of(
//           context,
//         ).push(MaterialPageRoute(builder: (context) => QuizPage(quiz: quiz)));
//       }
//     } catch (e) {
//       setState(() {
//         _isProcessing = false;
//         _resetQuizLoadingStates(difficulty);
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(context)!.errorGeneratingQuiz(e.toString()),
//               color: Theme.of(context).colorScheme.onErrorContainer,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     }
//   }

//   void _resetQuizLoadingStates(QuizDifficulty difficulty) {
//     switch (difficulty) {
//       case QuizDifficulty.easy:
//         _isQuickQuizLoading = false;
//         break;
//       case QuizDifficulty.medium:
//         _isPracticeTestLoading = false;
//         break;
//       case QuizDifficulty.hard:
//         _isChallengeLoading = false;
//         break;
//     }
//   }

//   /// Generate quiz specifically from all study materials
//   Future<void> _generateQuizFromAllMaterials() async {
//     if (_studyMaterials.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(context)!.noStudyMaterialsAvailable,
//               color: Theme.of(context).colorScheme.onSecondary,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.secondary,
//           ),
//         );
//       }
//       return;
//     }

//     setState(() {
//       _isAllMaterialsQuizLoading = true;
//     });

//     try {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(context)!.generatingComprehensiveQuiz,
//               color: Theme.of(context).colorScheme.onSecondary,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.secondary,
//           ),
//         );
//       }

//       // Generate quiz from all study materials with medium difficulty
//       final quiz = await _quizService.generateQuizFromMaterials(
//         materials: _studyMaterials,
//         difficulty: QuizDifficulty.medium,
//         questionCount: 12,
//         timeLimit: 25,
//         customTitle: AppLocalizations.of(context)!.comprehensiveQuizTitle,
//       );

//       setState(() {
//         _isAllMaterialsQuizLoading = false;
//       });

//       if (mounted) {
//         // Navigate to quiz page
//         Navigator.of(
//           context,
//         ).push(MaterialPageRoute(builder: (context) => QuizPage(quiz: quiz)));
//       }
//     } catch (e) {
//       setState(() {
//         _isAllMaterialsQuizLoading = false;
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(
//                 context,
//               )!.errorGeneratingComprehensiveQuiz(e.toString()),
//               color: Theme.of(context).colorScheme.onErrorContainer,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     }
//   }

//   /// Show dialog to select study plan for quiz generation
//   Future<StudyPlan?> _showStudyPlanSelectionDialog() async {
//     return showDialog<StudyPlan>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: TitleLargeText(
//               AppLocalizations.of(context)!.selectStudyPlan,
//               fontWeight: FontWeight.bold,
//             ),
//             content: SizedBox(
//               width: double.maxFinite,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   BodyMediumText(
//                     AppLocalizations.of(context)!.chooseStudyPlanForQuiz,
//                     color: Theme.of(
//                       context,
//                     ).colorScheme.onSurface.withValues(alpha: 0.7),
//                   ),
//                   const SizedBox(height: 16),
//                   Flexible(
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: _studyPlans.length,
//                       itemBuilder: (context, index) {
//                         final plan = _studyPlans[index];
//                         return Card(
//                           margin: const EdgeInsets.only(bottom: 8),
//                           child: ListTile(
//                             onTap: () => Navigator.of(context).pop(plan),
//                             leading: Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.secondary.withValues(alpha: 0.1),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Icon(
//                                 Icons.school,
//                                 color: Theme.of(context).colorScheme.secondary,
//                                 size: 20,
//                               ),
//                             ),
//                             title: TitleMediumText(
//                               plan.title,
//                               fontWeight: FontWeight.w600,
//                             ),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 BodySmallText(
//                                   '${plan.topics.length} ${AppLocalizations.of(context)!.topics} • ${plan.calculateProgress().toStringAsFixed(0)}% ${AppLocalizations.of(context)!.complete}',
//                                 ),
//                                 const SizedBox(height: 4),
//                                 LinearProgressIndicator(
//                                   value: plan.calculateProgress() / 100,
//                                   backgroundColor: Theme.of(
//                                     context,
//                                   ).colorScheme.outline.withValues(alpha: 0.3),
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                     Theme.of(context).colorScheme.secondary,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             trailing: Icon(
//                               Icons.arrow_forward_ios,
//                               size: 16,
//                               color: Theme.of(
//                                 context,
//                               ).colorScheme.onSurface.withValues(alpha: 0.4),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: LabelLargeText(
//                   AppLocalizations.of(context)!.cancel,
//                   color: Theme.of(
//                     context,
//                   ).colorScheme.onSurface.withValues(alpha: 0.7),
//                 ),
//               ),
//             ],
//           ),
//     );
//   }

//   /// Generate quiz from selected study plan
//   Future<void> _generateQuizFromPlan(
//     StudyPlan plan, {
//     required QuizDifficulty difficulty,
//     required int questionCount,
//     required int timeLimit,
//   }) async {
//     setState(() {
//       _isProcessing = true;
//     });

//     try {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(
//                 context,
//               )!.generatingQuizFromPlan(questionCount, plan.title),
//               color: Theme.of(context).colorScheme.onSecondary,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.secondary,
//           ),
//         );
//       }

//       final quiz = await _quizService.generateQuizFromStudyPlan(
//         studyPlan: plan,
//         difficulty: difficulty,
//         questionCount: questionCount,
//         timeLimit: timeLimit,
//       );

//       setState(() {
//         _isProcessing = false;
//         _resetQuizLoadingStates(difficulty);
//       });

//       if (mounted) {
//         // Navigate to quiz page
//         Navigator.of(
//           context,
//         ).push(MaterialPageRoute(builder: (context) => QuizPage(quiz: quiz)));
//       }
//     } catch (e) {
//       setState(() {
//         _isProcessing = false;
//         _resetQuizLoadingStates(difficulty);
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(context)!.errorGeneratingQuiz(e.toString()),
//               color: Theme.of(context).colorScheme.onErrorContainer,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     }
//   }

//   // Plan management methods
//   Future<void> _deletePlan(String planId) async {
//     try {
//       // Delete from database first
//       await _planRepository.deletePlan(planId);

//       // Then remove from local state
//       setState(() {
//         _studyPlans.removeWhere((plan) => plan.id == planId);
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(context)!.studyPlanDeleted,
//               color: Theme.of(context).colorScheme.onSecondary,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.secondary,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('Error deleting study plan: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(
//                 context,
//               )!.errorDeletingStudyPlan(e.toString()),
//               color: Theme.of(context).colorScheme.onErrorContainer,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _refreshData() async {
//     await _loadPersistedData();
//   }

//   Future<void> _startQuizFromPlan(StudyPlan plan) async {
//     try {
//       setState(() {
//         _isProcessing = true;
//         _processingPlanId = plan.id;
//       });

//       // Show loading snackbar
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       Theme.of(context).colorScheme.onSecondary,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 BodyMediumText(AppLocalizations.of(context)!.generatingQuiz),
//               ],
//             ),
//             backgroundColor: Theme.of(context).colorScheme.secondary,
//             duration: const Duration(
//               seconds: 30,
//             ), // Long duration since quiz generation takes time
//           ),
//         );
//       }

//       final quiz = await _quizService.generateQuizFromStudyPlan(
//         studyPlan: plan,
//         difficulty: QuizDifficulty.medium,
//         questionCount: 10,
//         timeLimit: 15,
//       );

//       setState(() {
//         _isProcessing = false;
//         _processingPlanId = null;
//       });

//       // Hide loading snackbar
//       if (mounted) {
//         ScaffoldMessenger.of(context).hideCurrentSnackBar();

//         // Navigate to quiz
//         Navigator.of(
//           context,
//         ).push(MaterialPageRoute(builder: (context) => QuizPage(quiz: quiz)));
//       }
//     } catch (e) {
//       setState(() {
//         _isProcessing = false;
//         _processingPlanId = null;
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).hideCurrentSnackBar();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(context)!.errorGeneratingQuiz(e.toString()),
//               color: Theme.of(context).colorScheme.onErrorContainer,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     }
//   }

//   // Progress tracking methods
//   Future<void> _updateTopicProgress(
//     String planId,
//     String topicId,
//     double progress,
//   ) async {
//     try {
//       // Find the plan
//       final planIndex = _studyPlans.indexWhere((plan) => plan.id == planId);
//       if (planIndex == -1) return;

//       final plan = _studyPlans[planIndex];
//       final updatedPlan = plan.updateTopicProgress(topicId, progress);

//       // Update local state
//       setState(() {
//         _studyPlans[planIndex] = updatedPlan;
//       });

//       // Persist to database
//       await _planRepository.updatePlan(updatedPlan);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(
//                 context,
//               )!.progressUpdated(progress.toStringAsFixed(0)),
//             ),
//             backgroundColor: Theme.of(context).colorScheme.secondary,
//             duration: const Duration(seconds: 1),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(context)!.errorUpdatingProgress(e.toString()),
//               color: Theme.of(context).colorScheme.onErrorContainer,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _markTopicComplete(String planId, String topicId) async {
//     try {
//       final planIndex = _studyPlans.indexWhere((plan) => plan.id == planId);
//       if (planIndex == -1) return;

//       final plan = _studyPlans[planIndex];

//       final updatedPlan = plan.markTopicComplete(topicId);

//       setState(() {
//         _studyPlans[planIndex] = updatedPlan;
//       });

//       await _planRepository.updatePlan(updatedPlan);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(context)!.topicMarkedComplete,
//               color: Theme.of(context).colorScheme.onSurfaceVariant,
//             ),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 1),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(
//                 context,
//               )!.errorMarkingTopicComplete(e.toString()),
//               color: Theme.of(context).colorScheme.onErrorContainer,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _startTopic(String planId, String topicId) async {
//     try {
//       final planIndex = _studyPlans.indexWhere((plan) => plan.id == planId);
//       if (planIndex == -1) return;

//       final plan = _studyPlans[planIndex];
//       final updatedPlan = plan.startTopic(topicId);

//       setState(() {
//         _studyPlans[planIndex] = updatedPlan;
//       });

//       await _planRepository.updatePlan(updatedPlan);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(context)!.topicStarted,
//               color: Theme.of(context).colorScheme.onSecondary,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.secondary,
//             duration: const Duration(seconds: 1),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: BodyMediumText(
//               AppLocalizations.of(context)!.errorStartingTopic(e.toString()),
//               color: Theme.of(context).colorScheme.onErrorContainer,
//             ),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     }
//   }

//   void _showStudyPlanTopics(StudyPlan plan) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => _buildStudyPlanTopicsSheet(plan),
//     );
//   }

//   Widget _buildStudyPlanTopicsSheet(StudyPlan plan) {
//     return StatefulBuilder(
//       builder: (context, setSheetState) {
//         return DraggableScrollableSheet(
//           initialChildSize: 0.7,
//           minChildSize: 0.5,
//           maxChildSize: 0.95,
//           builder: (context, scrollController) {
//             // Get the current plan state
//             final currentPlan = _studyPlans.firstWhere(
//               (p) => p.id == plan.id,
//               orElse: () => plan,
//             );

//             return Column(
//               children: [
//                 // Handle
//                 Container(
//                   margin: const EdgeInsets.only(top: 8),
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Theme.of(
//                       context,
//                     ).colorScheme.outline.withValues(alpha: 0.4),
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),

//                 // Header
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       HeadlineSmallText(
//                         currentPlan.title,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       const SizedBox(height: 8),

//                       // Overall progress
//                       Row(
//                         children: [
//                           Expanded(
//                             child: LinearProgressIndicator(
//                               value: currentPlan.calculateProgress() / 100,
//                               backgroundColor: Theme.of(
//                                 context,
//                               ).colorScheme.outline.withValues(alpha: 0.3),
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 Theme.of(context).colorScheme.secondary,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           LabelMediumText(
//                             '${currentPlan.calculateProgress().toStringAsFixed(0)}% ${AppLocalizations.of(context)!.complete}',
//                             fontWeight: FontWeight.bold,
//                             color: Theme.of(context).colorScheme.secondary,
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 8),

//                       // Stats row
//                       Row(
//                         children: [
//                           _buildTopicStat(
//                             AppLocalizations.of(context)!.totalTopics,
//                             currentPlan.topics.length.toString(),
//                             Icons.list_alt,
//                           ),
//                           const SizedBox(width: 16),
//                           _buildTopicStat(
//                             AppLocalizations.of(context)!.completedStatus,
//                             currentPlan
//                                 .getCompletionStats()['completed']
//                                 .toString(),
//                             Icons.check_circle,
//                           ),
//                           const SizedBox(width: 16),
//                           _buildTopicStat(
//                             AppLocalizations.of(context)!.inProgress,
//                             currentPlan
//                                 .getCompletionStats()['inProgress']
//                                 .toString(),
//                             Icons.play_circle,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 const Divider(height: 1),

//                 // Topics list
//                 Expanded(
//                   child: ListView.builder(
//                     controller: scrollController,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     itemCount: currentPlan.topics.length,
//                     itemBuilder: (context, index) {
//                       final topic = currentPlan.topics[index];
//                       return _buildTopicListItem(
//                         currentPlan,
//                         topic,
//                         () => setSheetState(() {}),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildTopicStat(String label, String value, IconData icon) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
//         const SizedBox(width: 4),
//         LabelMediumText(
//           value,
//           fontWeight: FontWeight.bold,
//           color: Theme.of(context).colorScheme.onSurface,
//         ),
//         const SizedBox(width: 2),
//         LabelSmallText(
//           label,
//           color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
//         ),
//       ],
//     );
//   }

//   Widget _buildTopicListItem(
//     StudyPlan plan,
//     StudyTopic topic, [
//     void Function()? onUpdate,
//   ]) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: InkWell(
//         onTap: () => _showTopicDetailsDialog(plan, topic, onUpdate),
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.surface,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: Theme.of(
//                 context,
//               ).colorScheme.outline.withValues(alpha: 0.2),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   // Status icon
//                   Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: _getTopicStatusColor(
//                         topic.status,
//                       ).withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Icon(
//                       _getTopicStatusIcon(topic.status),
//                       size: 16,
//                       color: _getTopicStatusColor(topic.status),
//                     ),
//                   ),
//                   const SizedBox(width: 12),

//                   // Topic title
//                   Expanded(
//                     child: TitleMediumText(
//                       topic.title,
//                       fontWeight: FontWeight.w600,
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//                   ),

//                   // Progress percentage
//                   LabelMediumText(
//                     '${topic.progressPercentage.toStringAsFixed(0)}%',
//                     fontWeight: FontWeight.bold,
//                     color: _getTopicStatusColor(topic.status),
//                   ),

//                   const SizedBox(width: 8),
//                   Icon(
//                     Icons.arrow_forward_ios,
//                     size: 14,
//                     color: Theme.of(
//                       context,
//                     ).colorScheme.onSurface.withValues(alpha: 0.4),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 8),

//               // Progress bar
//               LinearProgressIndicator(
//                 value: topic.progressPercentage / 100,
//                 backgroundColor: Theme.of(
//                   context,
//                 ).colorScheme.outline.withValues(alpha: 0.2),
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   _getTopicStatusColor(topic.status),
//                 ),
//               ),

//               const SizedBox(height: 8),

//               // Topic description and metadata
//               BodySmallText(
//                 topic.description,
//                 color: Theme.of(
//                   context,
//                 ).colorScheme.onSurface.withValues(alpha: 0.7),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),

//               const SizedBox(height: 8),

//               // Metadata row
//               Row(
//                 children: [
//                   Icon(
//                     Icons.schedule,
//                     size: 14,
//                     color: Theme.of(
//                       context,
//                     ).colorScheme.onSurface.withValues(alpha: 0.6),
//                   ),
//                   const SizedBox(width: 4),
//                   LabelSmallText(
//                     '${topic.estimatedMinutes} ${AppLocalizations.of(context)!.minutes}',
//                     color: Theme.of(
//                       context,
//                     ).colorScheme.onSurface.withValues(alpha: 0.6),
//                   ),

//                   const SizedBox(width: 16),

//                   Icon(
//                     Icons.lightbulb_outline,
//                     size: 14,
//                     color: Theme.of(
//                       context,
//                     ).colorScheme.onSurface.withValues(alpha: 0.6),
//                   ),
//                   const SizedBox(width: 4),
//                   LabelSmallText(
//                     '${topic.keyConceptsList.length} ${AppLocalizations.of(context)!.concepts}',
//                     color: Theme.of(
//                       context,
//                     ).colorScheme.onSurface.withValues(alpha: 0.6),
//                   ),

//                   const Spacer(),

//                   // Quick action buttons
//                   if (topic.status != StudyTopicStatus.completed) ...[
//                     if (topic.status == StudyTopicStatus.notStarted)
//                       InkWell(
//                         onTap: () {
//                           Navigator.of(context).pop();
//                           _startTopic(plan.id, topic.id);
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Theme.of(
//                               context,
//                             ).colorScheme.secondary.withValues(alpha: 0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: LabelSmallText(
//                             AppLocalizations.of(context)!.start,
//                             color: Theme.of(context).colorScheme.secondary,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     const SizedBox(width: 8),
//                     InkWell(
//                       onTap: () {
//                         Navigator.of(context).pop();
//                         _markTopicComplete(plan.id, topic.id);
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.green.withValues(alpha: 0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: LabelSmallText(
//                           AppLocalizations.of(context)!.complete,
//                           color: Colors.green,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ] else
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.green.withValues(alpha: 0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.check, size: 12, color: Colors.green),
//                           const SizedBox(width: 4),
//                           LabelSmallText(
//                             AppLocalizations.of(context)!.done,
//                             color: Colors.green,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showTopicDetailsDialog(
//     StudyPlan plan,
//     StudyTopic topic, [
//     void Function()? onUpdate,
//   ]) {
//     showDialog(
//       context: context,
//       builder: (context) => _buildTopicDetailsDialog(plan, topic, onUpdate),
//     );
//   }

//   Widget _buildTopicDetailsDialog(
//     StudyPlan plan,
//     StudyTopic topic, [
//     void Function()? onUpdate,
//   ]) {
//     return StatefulBuilder(
//       builder: (context, setDialogState) {
//         // Get the current topic state from the plan
//         final currentPlan = _studyPlans.firstWhere(
//           (p) => p.id == plan.id,
//           orElse: () => plan,
//         );
//         final currentTopic = currentPlan.topics.firstWhere(
//           (t) => t.id == topic.id,
//           orElse: () => topic,
//         );

//         return Dialog(
//           child: Container(
//             width: double.maxFinite,
//             height: MediaQuery.of(context).size.height * 0.8,
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.surface,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               children: [
//                 // Header
//                 Container(
//                   padding: const EdgeInsets.all(_spacing4),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         _getTopicStatusColor(
//                           currentTopic.status,
//                         ).withValues(alpha: 0.1),
//                         _getTopicStatusColor(
//                           currentTopic.status,
//                         ).withValues(alpha: 0.05),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(16),
//                       topRight: Radius.circular(16),
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: _getTopicStatusColor(
//                                 currentTopic.status,
//                               ).withValues(alpha: 0.2),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               _getTopicStatusIcon(currentTopic.status),
//                               color: _getTopicStatusColor(currentTopic.status),
//                               size: 24,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: HeadlineSmallText(
//                               currentTopic.title,
//                               fontWeight: FontWeight.bold,
//                               color: Theme.of(context).colorScheme.onSurface,
//                             ),
//                           ),
//                           IconButton(
//                             onPressed: () => Navigator.of(context).pop(),
//                             icon: const Icon(Icons.close),
//                             style: IconButton.styleFrom(
//                               backgroundColor: Theme.of(
//                                 context,
//                               ).colorScheme.surface.withValues(alpha: 0.8),
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 16),

//                       // Progress indicator
//                       Row(
//                         children: [
//                           Expanded(
//                             child: LinearProgressIndicator(
//                               value: currentTopic.progressPercentage / 100,
//                               backgroundColor: Theme.of(
//                                 context,
//                               ).colorScheme.outline.withValues(alpha: 0.3),
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 _getTopicStatusColor(currentTopic.status),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           LabelLargeText(
//                             '${currentTopic.progressPercentage.toStringAsFixed(0)}% ${AppLocalizations.of(context)!.complete}',
//                             fontWeight: FontWeight.bold,
//                             color: _getTopicStatusColor(currentTopic.status),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 12),

//                       // Metadata row
//                       Row(
//                         children: [
//                           _buildTopicMetadata(
//                             Icons.schedule,
//                             '${currentTopic.estimatedMinutes} ${AppLocalizations.of(context)!.minutes}',
//                           ),
//                           const SizedBox(width: 24),
//                           _buildTopicMetadata(
//                             Icons.lightbulb_outline,
//                             '${currentTopic.keyConceptsList.length} ${AppLocalizations.of(context)!.concepts}',
//                           ),
//                           if (currentTopic.practiceProblems.isNotEmpty) ...[
//                             const SizedBox(width: 24),
//                             _buildTopicMetadata(
//                               Icons.quiz,
//                               '${currentTopic.practiceProblems.length} ${AppLocalizations.of(context)!.problems}',
//                             ),
//                           ],
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Content
//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.all(_spacing4),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Description
//                         _buildTopicSection(
//                           AppLocalizations.of(context)!.description,
//                           Icons.description,
//                           child: BodyLargeText(
//                             currentTopic.description,
//                             color: Theme.of(context).colorScheme.onSurface,
//                           ),
//                         ),

//                         const SizedBox(height: _spacing6),

//                         // Key Concepts
//                         if (currentTopic.keyConceptsList.isNotEmpty) ...[
//                           _buildTopicSection(
//                             AppLocalizations.of(context)!.keyConcepts,
//                             Icons.lightbulb_outline,
//                             child: Wrap(
//                               spacing: 8,
//                               runSpacing: 8,
//                               children:
//                                   currentTopic.keyConceptsList
//                                       .map(
//                                         (concept) => Container(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 12,
//                                             vertical: 8,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: Theme.of(context)
//                                                 .colorScheme
//                                                 .secondaryContainer
//                                                 .withValues(alpha: 0.3),
//                                             borderRadius: BorderRadius.circular(
//                                               16,
//                                             ),
//                                             border: Border.all(
//                                               color: Theme.of(context)
//                                                   .colorScheme
//                                                   .secondary
//                                                   .withValues(alpha: 0.2),
//                                             ),
//                                           ),
//                                           child: BodyMediumText(
//                                             concept,
//                                             color:
//                                                 Theme.of(context)
//                                                     .colorScheme
//                                                     .onSecondaryContainer,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       )
//                                       .toList(),
//                             ),
//                           ),
//                           const SizedBox(height: _spacing6),
//                         ],

//                         // Practice Problems
//                         if (currentTopic.practiceProblems.isNotEmpty) ...[
//                           _buildTopicSection(
//                             AppLocalizations.of(context)!.practiceProblems,
//                             Icons.quiz,
//                             child: Column(
//                               children:
//                                   currentTopic.practiceProblems
//                                       .asMap()
//                                       .entries
//                                       .map((entry) {
//                                         final index = entry.key;
//                                         final problem = entry.value;
//                                         return Container(
//                                           margin: const EdgeInsets.only(
//                                             bottom: 12,
//                                           ),
//                                           padding: const EdgeInsets.all(16),
//                                           decoration: BoxDecoration(
//                                             color:
//                                                 Theme.of(
//                                                   context,
//                                                 ).colorScheme.surface,
//                                             borderRadius: BorderRadius.circular(
//                                               12,
//                                             ),
//                                             border: Border.all(
//                                               color: Theme.of(context)
//                                                   .colorScheme
//                                                   .outline
//                                                   .withValues(alpha: 0.2),
//                                             ),
//                                           ),
//                                           child: Row(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Container(
//                                                 width: 24,
//                                                 height: 24,
//                                                 decoration: BoxDecoration(
//                                                   color:
//                                                       Theme.of(
//                                                         context,
//                                                       ).colorScheme.secondary,
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                 ),
//                                                 child: Center(
//                                                   child: LabelSmallText(
//                                                     '${index + 1}',
//                                                     color:
//                                                         Theme.of(context)
//                                                             .colorScheme
//                                                             .onSecondary,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 12),
//                                               Expanded(
//                                                 child: BodyMediumText(problem),
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       })
//                                       .toList(),
//                             ),
//                           ),
//                           const SizedBox(height: _spacing6),
//                         ],

//                         // Completion info
//                         if (currentTopic.completedAt != null) ...[
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: Colors.green.withValues(alpha: 0.1),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: Colors.green.withValues(alpha: 0.2),
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.celebration,
//                                   color: Colors.green,
//                                   size: 24,
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       TitleMediumText(
//                                         AppLocalizations.of(
//                                           context,
//                                         )!.topicCompleted,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.green,
//                                       ),
//                                       BodySmallText(
//                                         '${AppLocalizations.of(context)!.completedOn} ${_formatDate(currentTopic.completedAt!)}',
//                                         color: Colors.green.withValues(
//                                           alpha: 0.8,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Action buttons
//                 Container(
//                   padding: const EdgeInsets.all(_spacing4),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.surfaceContainerHighest
//                         .withValues(alpha: 0.3),
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(16),
//                       bottomRight: Radius.circular(16),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       if (currentTopic.status !=
//                           StudyTopicStatus.completed) ...[
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: () async {
//                               await _startTopic(plan.id, currentTopic.id);
//                               setDialogState(() {}); // Refresh dialog
//                               onUpdate?.call(); // Refresh parent sheet
//                             },
//                             icon: Icon(
//                               currentTopic.status == StudyTopicStatus.notStarted
//                                   ? Icons.play_arrow
//                                   : Icons.play_circle,
//                             ),
//                             label: LabelLargeText(
//                               currentTopic.status == StudyTopicStatus.notStarted
//                                   ? AppLocalizations.of(context)!.startTopic
//                                   : AppLocalizations.of(
//                                     context,
//                                   )!.continueAction,
//                               color: Theme.of(context).colorScheme.onSecondary,
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   Theme.of(context).colorScheme.secondary,
//                               foregroundColor:
//                                   Theme.of(context).colorScheme.onSecondary,
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: () async {
//                               await _markTopicComplete(
//                                 plan.id,
//                                 currentTopic.id,
//                               );
//                               setDialogState(() {}); // Refresh dialog
//                               onUpdate?.call(); // Refresh parent sheet
//                             },
//                             icon: const Icon(Icons.check_circle),
//                             label: LabelLargeText(
//                               AppLocalizations.of(context)!.markComplete,
//                               color: Theme.of(context).colorScheme.onSecondary,
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                             ),
//                           ),
//                         ),
//                       ] else ...[
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: () async {
//                               await _updateTopicProgress(
//                                 plan.id,
//                                 currentTopic.id,
//                                 0.0,
//                               );
//                               setDialogState(() {}); // Refresh dialog
//                               onUpdate?.call(); // Refresh parent sheet
//                             },
//                             icon: const Icon(Icons.refresh),
//                             label: LabelLargeText(
//                               AppLocalizations.of(context)!.markIncomplete,
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   Theme.of(context).colorScheme.error,
//                               foregroundColor:
//                                   Theme.of(context).colorScheme.onError,
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTopicMetadata(IconData icon, String text) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(
//           icon,
//           size: 16,
//           color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
//         ),
//         const SizedBox(width: 4),
//         BodySmallText(
//           text,
//           color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
//           fontWeight: FontWeight.w500,
//         ),
//       ],
//     );
//   }

//   Widget _buildTopicSection(
//     String title,
//     IconData icon, {
//     required Widget child,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Theme.of(
//                   context,
//                 ).colorScheme.secondary.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 icon,
//                 size: 18,
//                 color: Theme.of(context).colorScheme.secondary,
//               ),
//             ),
//             const SizedBox(width: 8),
//             TitleMediumText(
//               title,
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.onSurface,
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         child,
//       ],
//     );
//   }

//   IconData _getTopicStatusIcon(StudyTopicStatus status) {
//     switch (status) {
//       case StudyTopicStatus.completed:
//         return Icons.check_circle;
//       case StudyTopicStatus.inProgress:
//         return Icons.play_circle;
//       case StudyTopicStatus.needsReview:
//         return Icons.refresh;
//       case StudyTopicStatus.notStarted:
//         return Icons.radio_button_unchecked;
//     }
//   }

//   Color _getTopicStatusColor(StudyTopicStatus status) {
//     switch (status) {
//       case StudyTopicStatus.completed:
//         return Colors.green;
//       case StudyTopicStatus.inProgress:
//         return Theme.of(context).colorScheme.secondary;
//       case StudyTopicStatus.needsReview:
//         return Colors.orange;
//       case StudyTopicStatus.notStarted:
//         return Theme.of(context).colorScheme.outline;
//     }
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date).inDays;

//     if (difference == 0) {
//       return AppLocalizations.of(context)!.today;
//     } else if (difference == 1) {
//       return AppLocalizations.of(context)!.yesterday;
//     } else if (difference < 7) {
//       return AppLocalizations.of(context)!.daysAgo(difference);
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }
// }
