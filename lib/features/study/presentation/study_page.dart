import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common_widgets/math_symbols_widget.dart';
import '../data/services/study_plan_service.dart';
import '../data/services/quiz_service.dart';
import '../domain/models/study_material.dart' as study;
import '../domain/models/quiz.dart';
import 'bloc/study_bloc.dart';
import 'bloc/study_event.dart';
import 'bloc/study_state.dart';
import 'quiz_page.dart';
import 'quiz_history_page.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  final StudyPlanService _studyPlanService = StudyPlanService();
  final QuizService _quizService = QuizService();

  // Quiz button loading states
  bool _isQuickQuizLoading = false;
  bool _isPracticeTestLoading = false;
  bool _isChallengeLoading = false;
  bool _isAllMaterialsQuizLoading = false;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  
  // Controllers for text input
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _mathSymbolsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeServices();
    _loadStudyMaterials();
  }

  Future<void> _initializeServices() async {
    try {
      await _studyPlanService.initialize();
      await _quizService.initialize();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  void _loadStudyMaterials() {
    context.read<StudyBloc>().add(const StudyEvent.loadMaterials());
  }

  void _refreshData() {
    context.read<StudyBloc>().add(const StudyEvent.refreshMaterials());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _mathSymbolsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Materials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: BlocListener<StudyBloc, StudyState>(
        listener: (context, state) {
          state.maybeWhen(
            materialUploaded: (material, allMaterials) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully uploaded: ${material.title}'),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              );
            },
            materialDeleted: (materialId, remainingMaterials) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Material deleted successfully'),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              );
            },
            error: (failure, materials) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${failure.message}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
            orElse: () {},
          );
        },
        child: Column(
          children: [
            // Tab Bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                labelColor: Theme.of(context).colorScheme.onSecondary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(icon: Icon(Icons.upload_file), text: 'Upload'),
                  Tab(icon: Icon(Icons.library_books), text: 'My Materials'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildUploadTab(), _buildMaterialsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Upload Study Material',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload images or add text content to create your personalized study materials.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Upload Options
          Row(
            children: [
              Expanded(
                child: _buildUploadButton(
                  icon: Icons.camera_alt,
                  title: 'Take Photo',
                  subtitle: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUploadButton(
                  icon: Icons.photo_library,
                  title: 'From Gallery',
                  subtitle: 'Choose Image',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Text Input Option
          _buildTextInputSection(),
          const SizedBox(height: 24),

          // Math Symbols Widget
          MathSymbolsWidget(controller: _mathSymbolsController),
        ],
      ),
    );
  }

  Widget _buildMaterialsTab() {
    return BlocBuilder<StudyBloc, StudyState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Center(
            child: Text('Welcome! Start by loading your materials.'),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          processing: (message, materials) => Column(
            children: [
              LinearProgressIndicator(
                backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              if (materials != null && materials.isNotEmpty)
                Expanded(child: _buildMaterialsList(materials)),
            ],
          ),
          materialsLoaded: (materials, filteredMaterials, searchQuery) {
            final displayMaterials = filteredMaterials ?? materials;
            return _buildLoadedMaterialsContent(materials, displayMaterials, searchQuery);
          },
          materialUploaded: (material, allMaterials) =>
              _buildLoadedMaterialsContent(allMaterials, allMaterials, null),
          materialDeleted: (materialId, remainingMaterials) =>
              _buildLoadedMaterialsContent(remainingMaterials, remainingMaterials, null),
          error: (failure, materials) => Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        failure.message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (materials != null && materials.isNotEmpty)
                Expanded(child: _buildMaterialsList(materials)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadedMaterialsContent(
    List<dynamic> allMaterials,
    List<dynamic> displayMaterials,
    String? searchQuery,
  ) {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search materials...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery != null && searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<StudyBloc>().add(const StudyEvent.clearSearch());
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onChanged: (query) {
              context.read<StudyBloc>().add(StudyEvent.searchMaterials(query: query));
            },
          ),
        ),
        const SizedBox(height: 16),

        // Test Your Knowledge Section
        if (allMaterials.isNotEmpty) _buildTestYourKnowledgeSection(allMaterials),

        // Materials List
        Expanded(
          child: displayMaterials.isEmpty
              ? _buildEmptyState(searchQuery)
              : _buildMaterialsList(displayMaterials),
        ),
      ],
    );
  }

  Widget _buildTestYourKnowledgeSection(List<dynamic> materials) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.4),
            Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.quiz_outlined,
                color: Theme.of(context).colorScheme.secondary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Test Your Knowledge',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Generate personalized quizzes from your study materials',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          
          // Generate Quiz with All Materials Button
          _buildAllMaterialsQuizButton(),
          const SizedBox(height: 12),
          
          // Other quiz options in a row
          Row(
            children: [
              Expanded(child: _buildQuickQuizButton()),
              const SizedBox(width: 8),
              Expanded(child: _buildPracticeTestButton()),
              const SizedBox(width: 8),
              Expanded(child: _buildChallengeButton()),
            ],
          ),
          const SizedBox(height: 16),
          
          // Quiz History Button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _navigateToQuizHistory(),
              icon: const Icon(Icons.history),
              label: const Text('View Quiz History'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllMaterialsQuizButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isAllMaterialsQuizLoading ? null : _generateQuizFromAllMaterials,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isAllMaterialsQuizLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              )
            else
              const Icon(Icons.quiz_outlined, size: 20),
            const SizedBox(width: 8),
            Text(
              _isAllMaterialsQuizLoading
                  ? 'Generating Quiz...'
                  : 'Generate Quiz with All Materials',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickQuizButton() {
    return _buildSmallQuizButton(
      'Quick Quiz',
      Icons.flash_on,
      _isQuickQuizLoading,
      _generateQuickQuiz,
    );
  }

  Widget _buildPracticeTestButton() {
    return _buildSmallQuizButton(
      'Practice Test',
      Icons.assignment,
      _isPracticeTestLoading,
      _generatePracticeTest,
    );
  }

  Widget _buildChallengeButton() {
    return _buildSmallQuizButton(
      'Challenge',
      Icons.emoji_events,
      _isChallengeLoading,
      _generateChallenge,
    );
  }

  Widget _buildSmallQuizButton(
    String label,
    IconData icon,
    bool isLoading,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            )
          else
            Icon(icon, size: 16),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(List<dynamic> materials) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final material = materials[index];
        return _buildMaterialCard(material);
      },
    );
  }

  Widget _buildMaterialCard(dynamic material) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showMaterialDetails(material),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    material.imageUrl != null ? Icons.image : Icons.text_fields,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      material.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteMaterial(material.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              if (material.description != null && material.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  material.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(material.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  if (material.extractedTopics.isNotEmpty)
                    Chip(
                      label: Text('${material.extractedTopics.length} topics'),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String? searchQuery) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery != null && searchQuery.isNotEmpty
                ? Icons.search_off
                : Icons.library_books,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery != null && searchQuery.isNotEmpty
                ? 'No materials found for "$searchQuery"'
                : 'No study materials yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery != null && searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Upload your first material from the Upload tab',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInputSection() {
    return BlocBuilder<StudyBloc, StudyState>(
      builder: (context, state) {
        final isProcessing = state.isLoading;
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.text_fields,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Text Content',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter title for your study material',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabled: !isProcessing,
                  ),
                  onChanged: (value) => _titleController.text = value,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Description (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabled: !isProcessing,
                  ),
                  onChanged: (value) => _descriptionController.text = value,
                ),
                const SizedBox(height: 12),
                TextField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Enter your text content here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabled: !isProcessing,
                  ),
                  onChanged: (value) => _contentController.text = value,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : _processTextContent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isProcessing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Processing...'),
                            ],
                          )
                        : const Text('Add Text Content'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Methods
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        await _showUploadDialog(pickedFile.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showUploadDialog(String imagePath) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Study Material'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title*',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }
                Navigator.of(context).pop();
                context.read<StudyBloc>().add(StudyEvent.uploadImage(
                  imagePath: imagePath,
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                ));
              },
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );
  }

  void _processTextContent() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and content')),
      );
      return;
    }

    context.read<StudyBloc>().add(StudyEvent.processText(
      content: content,
      title: title,
      description: description.isEmpty ? null : description,
    ));

    // Clear the form
    _titleController.clear();
    _descriptionController.clear();
    _contentController.clear();
  }

  void _deleteMaterial(String materialId) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Material'),
          content: const Text('Are you sure you want to delete this study material?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<StudyBloc>().add(StudyEvent.deleteMaterial(materialId: materialId));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showMaterialDetails(dynamic material) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(material.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (material.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      material.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (material.description != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Description:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(material.description!),
                ],
                if (material.extractedContent != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Extracted Content:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(material.extractedContent!),
                ],
                if (material.extractedTopics.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Topics:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: material.extractedTopics
                        .map<Widget>((topic) => Chip(
                              label: Text(topic),
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Quiz generation methods (using existing logic)
  Future<void> _generateQuizFromAllMaterials() async {
    final state = context.read<StudyBloc>().state;
    final materials = state.currentMaterials;
    
    if (materials == null || materials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No study materials available to generate quiz from'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isAllMaterialsQuizLoading = true;
    });

    try {
      final quiz = await _quizService.generateQuizFromMaterials(
        materials: materials.cast<study.StudyMaterial>(),
        questionCount: 10,
        difficulty: QuizDifficulty.medium,
      );
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizPage(quiz: quiz),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating quiz: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAllMaterialsQuizLoading = false;
        });
      }
    }
  }

  Future<void> _generateQuickQuiz() async {
    // Implementation for quick quiz
    setState(() {
      _isQuickQuizLoading = true;
    });
    
    // Simulate quiz generation
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isQuickQuizLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quick Quiz feature coming soon!')),
      );
    }
  }

  Future<void> _generatePracticeTest() async {
    // Implementation for practice test
    setState(() {
      _isPracticeTestLoading = true;
    });
    
    // Simulate quiz generation
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isPracticeTestLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Practice Test feature coming soon!')),
      );
    }
  }

  Future<void> _generateChallenge() async {
    // Implementation for challenge
    setState(() {
      _isChallengeLoading = true;
    });
    
    // Simulate quiz generation
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isChallengeLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge feature coming soon!')),
      );
    }
  }

  void _navigateToQuizHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QuizHistoryPage(),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}