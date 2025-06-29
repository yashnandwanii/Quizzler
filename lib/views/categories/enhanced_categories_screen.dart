import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:wallpaper_app/services/enhanced_category_service.dart';
import 'package:wallpaper_app/model/quiz_preferences_model.dart';
import 'package:wallpaper_app/views/quiz_preferences/quiz_preferences_screen.dart';

class EnhancedCategoriesScreen extends StatefulWidget {
  const EnhancedCategoriesScreen({super.key});

  @override
  State<EnhancedCategoriesScreen> createState() => _EnhancedCategoriesScreenState();
}

class _EnhancedCategoriesScreenState extends State<EnhancedCategoriesScreen> {
  List<QuizCategory> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedDifficulty = 'All';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    
    try {
      // Initialize enhanced categories if needed
      await EnhancedCategoryService.initializeEnhancedCategories();
      
      // Load categories
      final categories = await EnhancedCategoryService.getEnhancedCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() => _isLoading = false);
    }
  }

  List<QuizCategory> get filteredCategories {
    var filtered = _categories;
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((category) {
        final name = category.name.toLowerCase();
        final description = category.description.toLowerCase();
        final tags = category.availableTags.join(' ').toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return name.contains(query) || 
               description.contains(query) || 
               tags.contains(query);
      }).toList();
    }
    
    // Filter by difficulty
    if (_selectedDifficulty != 'All') {
      filtered = filtered.where((category) => 
          category.difficulty == _selectedDifficulty).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchAndFilter(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCategoriesGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.purple.shade600,
          ],
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.category, color: Colors.white, size: 28.sp),
          SizedBox(width: 12.w),
          Text(
            'Quiz Categories',
            style: GoogleFonts.robotoMono(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadCategories,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search categories, topics, or tags...',
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.clear, color: Colors.grey),
                      )
                    : null,
              ),
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Difficulty filter
          Row(
            children: [
              Text(
                'Difficulty:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Easy', 'Medium', 'Hard']
                        .map((difficulty) => Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: FilterChip(
                                label: Text(difficulty),
                                selected: _selectedDifficulty == difficulty,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedDifficulty = difficulty;
                                  });
                                },
                                selectedColor: Colors.blue.withOpacity(0.2),
                                checkmarkColor: Colors.blue,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = filteredCategories;
    
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.sp, color: Colors.grey.shade300),
            SizedBox(height: 16.h),
            Text(
              _searchQuery.isNotEmpty ? 'No categories found' : 'No categories available',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                'Try a different search term or filter',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildEnhancedCategoryCard(categories[index]);
        },
      ),
    );
  }

  Widget _buildEnhancedCategoryCard(QuizCategory category) {
    final color = Color(category.color);
    
    return GestureDetector(
      onTap: () => _navigateToQuizPreferences(category),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with difficulty and quiz count
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      category.difficulty,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${category.quizCount} played',
                    style: TextStyle(
                      color: color,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: category.iconPath.isNotEmpty
                          ? Image.asset(
                              category.iconPath,
                              width: 40.w,
                              height: 40.h,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.quiz,
                                  size: 32.sp,
                                  color: color,
                                );
                              },
                            )
                          : Icon(
                              Icons.quiz,
                              size: 32.sp,
                              color: color,
                            ),
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    // Title
                    Text(
                      category.name,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 8.h),
                    
                    // Description
                    Text(
                      category.description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 8.h),
                    
                    // Tags preview
                    if (category.availableTags.isNotEmpty)
                      Wrap(
                        spacing: 4.w,
                        children: category.availableTags.take(2).map((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            
            // Start button
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(12.w),
              child: ElevatedButton(
                onPressed: () => _navigateToQuizPreferences(category),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Configure & Start',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToQuizPreferences(QuizCategory category) {
    Get.to(
      () => QuizPreferencesScreen(category: category),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 400),
    );
  }
}