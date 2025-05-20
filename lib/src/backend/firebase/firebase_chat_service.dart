import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flashzone_web/src/model/chat_message.dart';
import 'package:flashzone_web/src/model/message_ref.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseChatService {
  Ref ref;
  FirebaseFirestore db;
  FirebaseStorage firebaseStorage;
  late CollectionReference _messagesCollection;
  FirebaseChatService({required this.ref, required this.db, required this.firebaseStorage}) {
    _messagesCollection = db.collection('messages');
  }

  // Get reference to a group's messages subcollection
  CollectionReference _chatCollection(String docId) => 
      _messagesCollection.doc(docId).collection('chats');

  
  Future<String> initiatePersonalChat({
    required FZUser sender,
    required FZUser receiver,
  }) async {
    final docRef = await _messagesCollection.add({
      MessageRef.userIdsKey: [sender.id, receiver.id],
      MessageRef.senderKey: sender.compactObject(),
      MessageRef.receiverKey: receiver.compactObject(),
    });
    return docRef.id;
  }
  

  Future<String?> findPersonalChat({
    required FZUser sender,
    required FZUser receiver,
  }) async {
    final docRef = await _messagesCollection
      .where(MessageRef.userIdsKey, arrayContains: sender.id)
      .where(MessageRef.userIdsKey, arrayContains: receiver.id)
      .limit(1)
      .get();

    if (docRef.docs.isNotEmpty) {
      return docRef.docs.first.id;
    } else {
      return null;
    }
  }

  Future<List<MessageRef>> getAllPersonalChatsForUser(
      String userId
    ) async {
    Query query = _messagesCollection
        .where(MessageRef.userIdsKey, arrayContains: userId);


    final snapshot = await query.get();
    
    return snapshot.docs
        .map((doc) => MessageRef.fromDataSnapshot(doc.id, doc.data() as Map<String, dynamic>))
        .where((message) => message != null)
        .cast<MessageRef>()
        .toList();
  }


  Future<String> getOrCreateRefForFamChat({
    required String famId,
  }) async {
    final docRef = await _messagesCollection
      .where(MessageRef.famIdKey, isEqualTo: famId)
      .limit(1)
      .get();

    if (docRef.docs.isNotEmpty) {
      return docRef.docs.first.id;
    } else {
      
      // Create a new document if it doesn't exist
      final newDocRef = await _messagesCollection.add({
        MessageRef.famIdKey: famId,
      });
      return newDocRef.id;
    }
  }

  // Stream of messages for a group (real-time updates)
  Stream<List<FZChatMessage>> chatStream(
    String groupId, {
    int limit = 50,
  }) {
    return _chatCollection(groupId)
        .orderBy('time', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FZChatMessage.fromDocSnapshot(doc.id, doc.data() as Map<String, dynamic>))
            .where((message) => message != null)
            .cast<FZChatMessage>()
            .toList());
  }

  // Get messages for a group (paginated)
  Future<List<FZChatMessage>> getChats(
    String groupId, {
    int limit = 50,
    DocumentSnapshot? lastDocumentSnapshot,
  }) async {
    Query query = _chatCollection(groupId)
        .orderBy('time', descending: true)
        .limit(limit);

    if (lastDocumentSnapshot != null) {
      query = query.startAfterDocument(lastDocumentSnapshot);
    }

    final snapshot = await query.get();
    
    return snapshot.docs
        .map((doc) => FZChatMessage.fromDocSnapshot(doc.id, doc.data() as Map<String, dynamic>))
        .where((message) => message != null)
        .cast<FZChatMessage>()
        .toList();
  }

  // Send a message
  Future<String> sendMessage(FZChatMessage message, String groupId) async {
    final docRef = await _chatCollection(groupId).add(message.creationObj());
    return docRef.id;
  }

}

// Probably useless now, but keeping for reference
/*
Future<bool> sendFamChat(FZChatMessage message, String famId) async {
    try {
      final docRef = await _messagesCollection.add(message.creationObj());
      await docRef.update({'id': docRef.id});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<FZChatMessage>> getFamChats(
    String famId, {
    int limit = 50,
    FZChatMessage? lastMessage,
  }) async {
    Query query = _messagesCollection
        .where('famId', isEqualTo: famId)
        .orderBy('time', descending: true)
        .limit(limit);

    if (lastMessage != null) {
      query = query.startAfter([lastMessage.time]);
    }

    final snapshot = await query.get();
    
    return snapshot.docs
        .map((doc) => FZChatMessage.fromDocSnapshot(doc.id, doc.data() as Map<String, dynamic>))
        .where((message) => message != null)
        .cast<FZChatMessage>()
        .toList();
  }

  // Stream of messages for a group (for real-time updates)
  Stream<List<FZChatMessage>> famChatStream(
    String famId, {
    int limit = 50,
  }) {
    return _messagesCollection
        .where('famId', isEqualTo: famId)
        .orderBy('time', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FZChatMessage.fromDocSnapshot(doc.id, doc.data() as Map<String, dynamic>))
            .where((message) => message != null)
            .cast<FZChatMessage>()
            .toList());
  }

  //TODO: Implement proper message streams
  

  Future<List<FZChatMessage>> getPersonalChats({
    required String userId,
    String? recepientId,
    int limit = 50,
    FZChatMessage? lastMessage,
    }) async {
      Query query = _messagesCollection
        .where('userIds', arrayContains: userId)
        .orderBy('time', descending: true)
        .limit(limit);

    if (lastMessage != null) {
      query = query.startAfter([lastMessage.time]);
    }

    final snapshot = await query.get();

    if(recepientId != null) {
      // Filter the results to only include documents that also contain recepientId
      List<DocumentSnapshot> filteredDocs = snapshot.docs.where((doc) {
        List<dynamic> userIds = doc.get('userIds') as List<dynamic>;
        return userIds.contains(recepientId);
      }).toList();
    }
    
    return snapshot.docs
        .map((doc) => FZChatMessage.fromDocSnapshot(doc.id, doc.data() as Map<String, dynamic>))
        .where((message) => message != null)
        .cast<FZChatMessage>()
        .toList();
  }

*/