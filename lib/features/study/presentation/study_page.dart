import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/services/study_plan_service.dart';
import '../data/services/quiz_service.dart';
import '../data/repository/study_material_repository.dart';
import '../data/repository/study_plan_repository.dart';
import '../domain/models/study_material.dart' as study;
import '../domain/models/study_plan.dart';
import '../domain/models/quiz.dart';
import 'quiz_page.dart';
import 'quiz_history_page.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  final StudyPlanService _studyPlanService = StudyPlanService();
  final QuizService _quizService = QuizService();
  final StudyMaterialRepository _materialRepository = StudyMaterialRepository();
  final StudyPlanRepository _planRepository = StudyPlanRepository();
  
  List<study.StudyMaterial> _studyMaterials = [];
  List<StudyPlan> _studyPlans = [];
  bool _isProcessing = false;
  String? _processingPlanId;
  
  // Quiz button loading states
  bool _isQuickQuizLoading = false;
  bool _isPracticeTestLoading = false;
  bool _isChallengeLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _studyPlanService.initialize();
      await _quizService.initialize();
      
      // Load persisted data
      await _loadPersistedData();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  Future<void> _loadPersistedData() async {
    try {
      setState(() {
        _isProcessing = true;
      });

      // Load study materials and plans in parallel
      final futures = await Future.wait([
        _materialRepository.getUserMaterials(),
        _planRepository.getUserPlans(),
      ]);

      final materials = futures[0] as List<study.StudyMaterial>;
      final plans = futures[1] as List<StudyPlan>;

      setState(() {
        _studyMaterials = materials;
        _studyPlans = plans;
        _isProcessing = false;
      });

      debugPrint('Loaded ${materials.length} materials and ${plans.length} plans from database');
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      debugPrint('Error loading persisted data: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading your study data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      body: Column(
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
              children: [
                _buildUploadTab(),
                _buildMaterialsTab(),
              ],
            ),
          ),
        ],
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
                      Icons.auto_awesome,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Upload Your Study Material',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Upload textbook pages, class notes, homework, or any math material. Our AI will create a personalized study plan just for you!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Loading Progress Bar
          if (_isProcessing) ...[
            _buildProcessingIndicator(),
            const SizedBox(height: 24),
          ],

          // Upload Options
          _buildUploadOption(
            icon: Icons.camera_alt,
            title: 'Take Photo',
            subtitle: 'Capture textbook pages, notes, or worksheets',
            onTap: () => _handlePhotoUpload(),
          ),

          const SizedBox(height: 16),

          _buildUploadOption(
            icon: Icons.photo_library,
            title: 'Upload from Gallery',
            subtitle: 'Select images from your photo library',
            onTap: () => _handleGalleryUpload(),
          ),

          const SizedBox(height: 16),

          _buildUploadOption(
            icon: Icons.edit_note,
            title: 'Type Material',
            subtitle: 'Enter text directly or paste from clipboard',
            onTap: () => _handleTextInput(),
          ),

          const SizedBox(height: 32),

          // Recent Uploads Section
          _buildRecentUploadsSection(),
        ],
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDisabled = _isProcessing;
    
    return Container(
      decoration: BoxDecoration(
        color: isDisabled 
            ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDisabled
              ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isDisabled 
                      ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4)
                      : Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDisabled
                            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDisabled
                            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isDisabled
                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentUploadsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Uploads',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        
        if (_studyMaterials.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.upload_file,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  'No materials uploaded yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload your first study material to get started!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _studyMaterials.length,
              itemBuilder: (context, index) {
                final material = _studyMaterials[index];
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              material.type == study.MaterialType.image 
                                  ? Icons.image 
                                  : Icons.text_snippet,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 20,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: material.status == study.MaterialStatus.completed
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.outline,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                material.status == study.MaterialStatus.completed
                                    ? Icons.check
                                    : Icons.access_time,
                                color: Theme.of(context).colorScheme.onSecondary,
                                size: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                material.title,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${material.extractedTopics.length} topics',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
            ),
          ),
      ],
    );
  }

  Widget _buildMaterialsTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Study Plans Section
          if (_studyPlans.isNotEmpty) ...[
            _buildStudyPlansSection(),
            const SizedBox(height: 32),
          ],
          
          // Quiz Section
          if (_studyMaterials.isNotEmpty) ...[
            _buildQuizSection(),
            const SizedBox(height: 32),
          ],
          
          // Materials Section
          Text(
            'My Study Materials',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_studyMaterials.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.library_books,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Study Materials',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload your first material to see it here and start building your personalized study plan.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _studyMaterials.length,
              itemBuilder: (context, index) {
                final material = _studyMaterials[index];
                return _buildMaterialCard(material);
              },
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildStudyPlansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Study Plans',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        
        // Horizontal scrollable plans
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _studyPlans.length,
            itemBuilder: (context, index) {
              return _buildStudyPlanCard(_studyPlans[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudyPlanCard(StudyPlan plan) {
    return Container(
      width: 280,
      height: 220,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
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
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
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
                Icons.auto_awesome,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  plan.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    _deletePlan(plan.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete Plan'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          
          Flexible(
            child: Text(
              plan.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          
          // Progress indicator
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: plan.calculateProgress() / 100,
                  backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${plan.calculateProgress().toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Plan stats
          Row(
            children: [
              Flexible(
                child: _buildStatChip(
                  icon: Icons.list_alt,
                  label: '${plan.topics.length} Topics',
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: _buildStatChip(
                  icon: Icons.schedule,
                  label: '${plan.totalEstimatedHours}h',
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _processingPlanId == plan.id ? null : () => _startQuizFromPlan(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: _processingPlanId == plan.id 
                    ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6)
                    : Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _processingPlanId == plan.id
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Generating...', style: TextStyle(fontSize: 12)),
                      ],
                    )
                  : const Text('Take Quiz', style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Processing Your Material',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI is analyzing your content and creating a personalized study plan...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress bar
          LinearProgressIndicator(
            backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.secondary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Processing steps
          Row(
            children: [
              _buildProcessingStep('📷', 'Upload', true),
              _buildProcessingStep('🔍', 'Analyze', true),
              _buildProcessingStep('📚', 'Generate Plan', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingStep(String emoji, String label, bool isCompleted) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCompleted 
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    )
                  : Text(
                      emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isCompleted 
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Practice Quizzes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const QuizHistoryPage(),
                  ),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('History'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.2),
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
                    Icons.quiz,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Test Your Knowledge',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Generate AI-powered quizzes based on your study materials to test your understanding and identify areas for improvement.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 20),
              
              // Quiz options
              Row(
                children: [
                  Expanded(
                    child: _buildQuizOptionButton(
                      icon: Icons.flash_on,
                      title: 'Quick Quiz',
                      subtitle: '5 questions • 10 min',
                      difficulty: QuizDifficulty.easy,
                      questionCount: 5,
                      timeLimit: 10,
                      isLoading: _isQuickQuizLoading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuizOptionButton(
                      icon: Icons.school,
                      title: 'Practice Test',
                      subtitle: '10 questions • 20 min',
                      difficulty: QuizDifficulty.medium,
                      questionCount: 10,
                      timeLimit: 20,
                      isLoading: _isPracticeTestLoading,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Challenge quiz (only if study plans exist)
              if (_studyPlans.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: _buildQuizOptionButton(
                    icon: Icons.emoji_events,
                    title: 'Challenge Mode',
                    subtitle: '15 questions • 30 min • Based on study plan',
                    difficulty: QuizDifficulty.hard,
                    questionCount: 15,
                    timeLimit: 30,
                    isFullWidth: true,
                    isLoading: _isChallengeLoading,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizOptionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required QuizDifficulty difficulty,
    required int questionCount,
    required int timeLimit,
    bool isFullWidth = false,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: isLoading ? null : () => _generateAndStartQuiz(
          difficulty: difficulty,
          questionCount: questionCount,
          timeLimit: timeLimit,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isFullWidth
              ? Row(
                  children: [
                    isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          )
                        : Icon(
                            icon,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 24,
                          ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                      size: 16,
                    ),
                  ],
                )
              : Column(
                  children: [
                    isLoading
                        ? SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          )
                        : Icon(
                            icon,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 32,
                          ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(study.StudyMaterial material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  material.type == study.MaterialType.image 
                      ? Icons.image 
                      : Icons.text_snippet,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      material.difficultyLevel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: material.status == study.MaterialStatus.completed
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.outline,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  material.status == study.MaterialStatus.completed
                      ? Icons.check
                      : Icons.access_time,
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 16,
                ),
              ),
            ],
          ),
          
          if (material.extractedTopics.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Topics Found:',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: material.extractedTopics.take(3).map((topic) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    topic,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (material.extractedTopics.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '+${material.extractedTopics.length - 3} more topics',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // Upload functionality methods
  Future<void> _handlePhotoUpload() async {
    try {
      // Check camera permission
      if (Platform.isAndroid) {
        final cameraStatus = await Permission.camera.request();
        if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
          _showPermissionDialog('Camera');
          return;
        }
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 85,
      );

      if (photo != null) {
        final File imageFile = File(photo.path);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('📷 Material captured! Starting AI analysis...'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        
        await _processUploadedMaterial(imageFile, study.MaterialType.image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing photo: $e')),
        );
      }
    }
  }

  Future<void> _handleGalleryUpload() async {
    try {
      // Check photo permission
      if (Platform.isAndroid) {
        final photosStatus = await Permission.photos.request();
        if (photosStatus.isDenied || photosStatus.isPermanentlyDenied) {
          _showPermissionDialog('Photo Library');
          return;
        }
      }

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📱 ${images.length} material(s) uploaded! Starting AI analysis...'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        
        for (final xFile in images) {
          final imageFile = File(xFile.path);
          await _processUploadedMaterial(imageFile, study.MaterialType.image);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading from gallery: $e')),
        );
      }
    }
  }

  void _handleTextInput() {
    showDialog(
      context: context,
      builder: (context) => _buildTextInputDialog(),
    );
  }

  Future<void> _processUploadedMaterial(File? imageFile, study.MaterialType type, {String? textContent}) async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final materialId = DateTime.now().millisecondsSinceEpoch.toString();
      final title = type == study.MaterialType.image 
          ? 'Study Material ${_studyMaterials.length + 1}'
          : 'Text Material ${_studyMaterials.length + 1}';
      
      // Analyze the material
      final studyMaterial = await _studyPlanService.analyzeMaterial(
        materialId: materialId,
        type: type,
        content: textContent,
        imageFile: imageFile,
        title: title,
      );

      // Handle image upload to Firebase Storage if needed
      study.StudyMaterial finalMaterial = studyMaterial;
      if (imageFile != null && type == study.MaterialType.image) {
        try {
          final downloadUrl = await _materialRepository.uploadImage(imageFile, materialId);
          finalMaterial = studyMaterial.copyWith(
            firebaseStoragePath: downloadUrl,
          );
        } catch (e) {
          debugPrint('Warning: Could not upload image to storage: $e');
          // Continue without Firebase Storage URL
        }
      }

      // Save material to database
      await _materialRepository.saveMaterial(finalMaterial);
      
      setState(() {
        _studyMaterials.add(finalMaterial);
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Material analyzed successfully! Study plan created!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      // Generate individual study plan for this material
      await _generateIndividualStudyPlan(finalMaterial);
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing material: $e')),
        );
      }
    }
  }

  void _showPermissionDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$permissionType Permission Required'),
        content: Text(
          'Please enable $permissionType access in your device settings to upload study materials.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputDialog() {
    final TextEditingController textController = TextEditingController();
    
    return AlertDialog(
      title: const Text('Add Study Material'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your study material text:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Paste or type your math content here...\n\nExample:\n• Chapter 5: Quadratic Equations\n• Solving ax² + bx + c = 0\n• Practice problems 1-15',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
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
          onPressed: () async {
            if (textController.text.trim().isNotEmpty) {
              Navigator.of(context).pop();
              
              // Process the text input
              await _processTextMaterial(textController.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          child: const Text('Add Material'),
        ),
      ],
    );
  }

  Future<void> _processTextMaterial(String text) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Processing text material...'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
    
    await _processUploadedMaterial(null, study.MaterialType.text, textContent: text);
  }

  Future<void> _generateIndividualStudyPlan(study.StudyMaterial material) async {
    try {
      setState(() {
        _isProcessing = true;
      });
      
      final studyPlan = await _studyPlanService.generateStudyPlan(
        materials: [material], // Only this material
        customTitle: "Plan: ${material.title}",
      );

      // Save study plan to database
      await _planRepository.savePlan(studyPlan);
      
      setState(() {
        _studyPlans.add(studyPlan);
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Study plan "${studyPlan.title}" created!'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating study plan: $e')),
        );
      }
    }
  }

  Future<void> _generateAndStartQuiz({
    required QuizDifficulty difficulty,
    required int questionCount,
    required int timeLimit,
  }) async {
    // Set the appropriate loading state based on difficulty
    setState(() {
      switch (difficulty) {
        case QuizDifficulty.easy:
          _isQuickQuizLoading = true;
          break;
        case QuizDifficulty.medium:
          _isPracticeTestLoading = true;
          break;
        case QuizDifficulty.hard:
          _isChallengeLoading = true;
          break;
      }
    });
    if (_studyMaterials.isEmpty) {
      setState(() {
        _resetQuizLoadingStates(difficulty);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No study materials available for quiz generation')),
        );
      }
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generating quiz with $questionCount questions...'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }

      Quiz quiz;
      
      // If challenge mode and study plans exist, generate from first study plan
      if (difficulty == QuizDifficulty.hard && _studyPlans.isNotEmpty) {
        quiz = await _quizService.generateQuizFromStudyPlan(
          studyPlan: _studyPlans.first,
          difficulty: difficulty,
          questionCount: questionCount,
          timeLimit: timeLimit,
        );
      } else {
        // Generate from study materials
        quiz = await _quizService.generateQuizFromMaterials(
          materials: _studyMaterials,
          difficulty: difficulty,
          questionCount: questionCount,
          timeLimit: timeLimit,
        );
      }

      setState(() {
        _isProcessing = false;
        _resetQuizLoadingStates(difficulty);
      });

      if (mounted) {
        // Navigate to quiz page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuizPage(quiz: quiz),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _resetQuizLoadingStates(difficulty);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating quiz: $e')),
        );
      }
    }
  }

  void _resetQuizLoadingStates(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        _isQuickQuizLoading = false;
        break;
      case QuizDifficulty.medium:
        _isPracticeTestLoading = false;
        break;
      case QuizDifficulty.hard:
        _isChallengeLoading = false;
        break;
    }
  }

  // Plan management methods
  Future<void> _deletePlan(String planId) async {
    try {
      // Delete from database first
      await _planRepository.deletePlan(planId);
      
      // Then remove from local state
      setState(() {
        _studyPlans.removeWhere((plan) => plan.id == planId);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Study plan deleted'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting study plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting study plan: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadPersistedData();
  }

  Future<void> _startQuizFromPlan(StudyPlan plan) async {
    try {
      setState(() {
        _isProcessing = true;
        _processingPlanId = plan.id;
      });

      // Show loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
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
                const SizedBox(width: 12),
                const Text('Generating quiz...'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 30), // Long duration since quiz generation takes time
          ),
        );
      }

      final quiz = await _quizService.generateQuizFromStudyPlan(
        studyPlan: plan,
        difficulty: QuizDifficulty.medium,
        questionCount: 10,
        timeLimit: 15,
      );

      setState(() {
        _isProcessing = false;
        _processingPlanId = null;
      });

      // Hide loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        // Navigate to quiz
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuizPage(quiz: quiz),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _processingPlanId = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating quiz: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}