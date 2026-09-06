# Firestore Document Structure Migration Guide

This guide explains how to migrate from field-based user isolation to path-based user isolation, should you choose to do so in the future.

## Current Structure (Field-based)

```
/documents/{documentId}
  - userId: "user123"
  - title: "..."
  - content: "..."

/collections/{documentId}
  - userId: "user123"
  - title: "..."
  - items: [...]
```

**Security**: Rules check that `request.auth.uid == resource.data.userId`

## Proposed Structure (Path-based)

```
/users/{userId}/documents/{documentId}
  - title: "..."
  - content: "..."

/users/{userId}/collections/{documentId}
  - title: "..."
  - items: [...]
```

**Security**: Rules check that `request.auth.uid == userId` (from path)

## Pros and Cons

### Current Structure (Field-based)
**Pros:**
- Simpler queries across all users (for admin features)
- Already implemented and working
- No migration needed
- Security rules are already deployed and secure

**Cons:**
- Slightly less efficient security rule evaluation
- Potential for accidentally querying without userId filter
- All user data in same collection (scaling considerations)

### Path-based Structure
**Pros:**
- Stronger isolation at the database level
- More efficient security rules (path-based checks)
- Better for very large scale (millions of users)
- Impossible to accidentally query other users' data

**Cons:**
- Requires data migration
- More complex admin queries (need to query across all users)
- Breaking change requiring app update
- Risk during migration

## Migration Decision Matrix

Consider migration if:
- [ ] You have millions of users
- [ ] You need stronger compliance guarantees
- [ ] You're building admin features and want clearer separation
- [ ] You're experiencing performance issues with current structure

Stay with current structure if:
- [x] Current security is sufficient
- [x] You have existing users and data
- [x] You don't need admin-level queries
- [x] Your app is already in production

## Migration Steps (If Needed)

### 1. Update Security Rules

```javascript
// Add new path-based rules alongside existing ones
match /users/{userId}/documents/{document} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

### 2. Update Repository Code

Example for a generic repository:

```dart
// Change from:
CollectionReference get _collection => firestore.collection('documents');

// To:
CollectionReference _getUserCollection(String userId) =>
  firestore.collection('users').doc(userId).collection('documents');

// Update queries:
Query query = _getUserCollection(userId)
    .orderBy('createdAt', descending: true);
```

### 3. Create Migration Script

```dart
Future<void> migrateUserData() async {
  final batch = firestore.batch();

  // Get all documents from old structure
  final oldDocs = await firestore.collection('documents').get();

  for (final doc in oldDocs.docs) {
    final data = doc.data();
    final userId = data['userId'];

    // Create in new structure
    final newRef = firestore
        .collection('users')
        .doc(userId)
        .collection('documents')
        .doc(doc.id);

    // Remove userId field as it's now in the path
    data.remove('userId');

    batch.set(newRef, data);
  }

  await batch.commit();
}
```

### 4. Phased Rollout

1. **Phase 1**: Deploy new structure support (read from both)
2. **Phase 2**: Run migration script
3. **Phase 3**: Update app to write to new structure
4. **Phase 4**: Remove old structure support

### 5. Update All Affected Code

- All repository classes
- Any direct Firestore queries
- Admin tools or scripts
- Backup procedures

## Recommendation

**For most use cases**: The field-based approach with proper security rules is sufficient and secure. The effort and risk of migration outweigh the benefits unless you're experiencing specific issues or compliance requirements.

The current implementation:
- Is secure with the deployed rules
- Works well for typical use cases
- Has proper authentication checks

Consider migration only if you encounter scaling issues or have new compliance requirements in the future.
