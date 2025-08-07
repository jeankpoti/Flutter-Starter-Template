# Firebase Security Rules Documentation

This document explains the security rules implemented for the Math AI application.

## Overview

The security rules enforce the following principles:
1. **Authentication Required**: All operations require user authentication
2. **User Data Isolation**: Users can only access their own data
3. **Data Integrity**: Prevent tampering with timestamps and ownership
4. **File Size Limits**: Prevent storage abuse through size restrictions
5. **Content Type Validation**: Only allow appropriate file types

## Firestore Rules

### Collections Protected

1. **homework** - Math problems and solutions
   - Users can only read, create, update, and delete their own homework
   - Creation timestamp is immutable
   - User ID cannot be changed after creation

2. **studyMaterials** - Study documents and materials
   - Users can only access their own study materials
   - Required fields: userId, createdAt, title

3. **studyPlans** - AI-generated study plans
   - Linked to study materials via studyMaterialId
   - Users can only access their own plans

4. **quizzes** - AI-generated quizzes
   - Linked to study materials via studyMaterialId
   - Users can only access their own quizzes

5. **content_reports** - For reporting inappropriate content
   - Any authenticated user can create reports
   - Reports cannot be modified or deleted by users
   - Only the reporter can view their own reports

### Key Security Features

- **Ownership Verification**: All documents must have a `userId` field matching the authenticated user
- **Timestamp Integrity**: `createdAt` timestamps are set by the server and cannot be modified
- **Required Fields Validation**: Documents must contain all required fields
- **Immutable Fields**: Critical fields like userId and createdAt cannot be changed after creation

## Storage Rules

### Storage Paths Protected

1. **homework_images/{userId}/{fileName}**
   - Max file size: 10MB
   - Only image files allowed
   - Users can only access their own images

2. **study_materials/{userId}/{fileName}**
   - Max file size: 50MB
   - Images and PDFs allowed
   - Users can only access their own materials

3. **profile_pictures/{userId}/{fileName}** (Future feature)
   - Max file size: 5MB
   - Only image files allowed
   - Read access for all authenticated users
   - Write access only for the owner

4. **temp/{userId}/{fileName}** (Optional)
   - Max file size: 100MB
   - For temporary uploads
   - Cannot be updated (only create/delete)

### File Validation

- **Content Type Checking**: Only allowed file types can be uploaded
- **Size Limits**: Different limits for different file types
- **Path-based Security**: User ID must be in the file path

## Implementation Notes

### For Developers

1. **Always include userId**: When creating documents, always include the authenticated user's ID
2. **Use ServerTimestamp**: For createdAt fields, use `FieldValue.serverTimestamp()`
3. **Handle Errors**: Security rule violations will throw permission-denied errors
4. **Test Thoroughly**: Test with different user accounts to ensure proper isolation

### Code Examples

**Creating a document (Dart/Flutter):**
```dart
await firestore.collection('homework').add({
  'userId': FirebaseAuth.instance.currentUser!.uid,
  'createdAt': FieldValue.serverTimestamp(),
  'problem': problemText,
  'solution': solutionText,
  // other fields...
});
```

**Uploading a file (Dart/Flutter):**
```dart
final userId = FirebaseAuth.instance.currentUser!.uid;
final ref = FirebaseStorage.instance
    .ref()
    .child('homework_images/$userId/$fileName');
await ref.putFile(imageFile);
```

## Deployment

To deploy these rules:

1. **Firestore Rules:**
   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Storage Rules:**
   ```bash
   firebase deploy --only storage:rules
   ```

3. **Both:**
   ```bash
   firebase deploy --only firestore:rules,storage:rules
   ```

## Testing

Before deploying to production:

1. Test with the Firebase Emulator Suite
2. Verify each rule with different user scenarios
3. Test edge cases (missing fields, wrong file types, etc.)
4. Monitor security rule evaluations in Firebase Console

## Monitoring

After deployment:

1. Monitor rule violations in Firebase Console
2. Set up alerts for excessive violations
3. Review Firebase Usage and Rules metrics
4. Adjust rules based on legitimate use cases

## Future Considerations

1. **Rate Limiting**: Consider Cloud Functions for rate limiting
2. **Quotas**: Implement per-user storage quotas
3. **Admin Access**: Add admin rules for content moderation
4. **Sharing**: If adding sharing features, update rules accordingly