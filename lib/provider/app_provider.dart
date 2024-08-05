import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mini_ml/models/data.dart';
import 'package:mini_ml/models/model.dart';
import 'package:mini_ml/models/project.dart';
import 'package:mini_ml/models/resource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  // Provider Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  late SharedPreferences _prefs;
  Project _projectProvider = Project();
  String _userStorageInMegaBytes = "0";
  num _totalResources = 0;

  // Provider Accessors
  FirebaseAuth get auth => _auth;
  bool get isLoading => _isLoading;
  Project get projectProvider => _projectProvider;
  String get userStorageInMegaBytes => _userStorageInMegaBytes;
  num get totalResources => _totalResources;

  // Lists Instances
  List<Project> _projects = [];
  // List Accessors
  List<Project> get projects => _projects;

  void setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void resetProviderState() {
    _projectProvider = Project();
    _userStorageInMegaBytes = "0";
    _projects = [];
    notifyListeners();
  }

  Future<void> setProjectProvider(Project project) async {
    try {
      _projectProvider = project;
      _prefs = await SharedPreferences.getInstance();
      await _prefs.setString(
          'recent-project-${_auth.currentUser?.uid ?? ''}', project.name);
      await fetchResources(project.id);
      notifyListeners();
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  Future<void> clearProjectProvider() async {
    try {
      _projectProvider = Project();
      _prefs = await SharedPreferences.getInstance();
      await _prefs.setString(
          'recent-project-${_auth.currentUser?.uid ?? ''}', '');
      notifyListeners();
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  void fetchTotalResource() {
    for (var project in projects) {
      _totalResources += project.getTotalResources();
    }
    notifyListeners();
  }

  Future<void> fetchAppData() async {
    try {
      if (_auth.currentUser != null) {
        await fetchUserStorage();
        await fetchProjects();
        await fetchPreferences();
        fetchTotalResource();
      } else {
        print('User Not Logged In');
      }
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  Future<void> fetchUserStorage() async {
    try {
      int totalSize = 0;
      final storageRef = FirebaseStorage.instance.ref();
      final ListResult result = await storageRef.listAll();

      for (Reference item in result.items) {
        final FullMetadata metadata = await item.getMetadata();
        totalSize += metadata.size ?? 0;
      }

      for (Reference prefix in result.prefixes) {
        totalSize += await _getFolderSize(prefix);
      }

      _userStorageInMegaBytes = (totalSize / (1024 * 1024)).toStringAsFixed(2);
      print('User Storage - $_userStorageInMegaBytes');
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  Future<int> _getFolderSize(Reference folderRef) async {
    int folderSize = 0;
    final ListResult result = await folderRef.listAll();

    for (Reference item in result.items) {
      final FullMetadata metadata = await item.getMetadata();
      folderSize += metadata.size ?? 0;
    }

    for (Reference prefix in result.prefixes) {
      folderSize += await _getFolderSize(prefix);
    }

    return folderSize;
  }

  Future<void> fetchPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      String? recentProject =
          _prefs.getString('recent-project-${_auth.currentUser?.uid ?? ''}');

      if (recentProject != null) {
        final project = _projects.firstWhere((p) => p.name == recentProject,
            orElse: () => Project());
        if (project.id.isNotEmpty) {
          setProjectProvider(project);
        }
      } else {
        print('No Recent Projects');
      }
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  Future<bool> checkForExistingProject(Project project) async {
    try {
      if (_auth.currentUser == null) {
        throw ('No user currently logged in');
      }

      final existingProjects = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('projects')
          .where('name', isEqualTo: project.name.toLowerCase())
          .get();

      return existingProjects.docs.isNotEmpty;
    } catch (error) {
      print('Error checking existing project: $error');
      throw FirebaseException(plugin: error.toString());
    }
  }

  Future<bool> checkForExistingResource(
      String projectId, Resource resource) async {
    try {
      if (_auth.currentUser == null) {
        throw ('No user currently logged in');
      }

      final collection =
          resource.resourceType == ResourceType.data ? 'data' : 'models';

      final existingResources = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('projects')
          .doc(projectId)
          .collection(collection)
          .where('name', isEqualTo: resource.name.toLowerCase())
          .get();

      return existingResources.docs.isNotEmpty;
    } catch (error) {
      print('Error checking existing resource: $error');
      throw FirebaseException(plugin: error.toString());
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception("User is not valid");
      }

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('projects')
          .doc(project.id);

      await docRef.update(project.toJson());
    } catch (error) {
      throw FirebaseException(plugin: error.toString());
    }
  }

  Future<void> deleteProject(Project project) async {
    try {
      if (_auth.currentUser == null) {
        throw ('No user currently logged in');
      }

      // Delete data and models
      await Future.wait([
        ...project.data.map((data) => deleteResource(project.id, data)),
        ...project.models.map((model) => deleteResource(project.id, model)),
      ]);

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('projects')
          .doc(project.id);

      await docRef.delete();
    } catch (error) {
      print('Error deleting project: $error');
      throw FirebaseException(plugin: error.toString());
    }
  }

  Future<void> fetchProjects({String? projectName}) async {
    try {
      if (_auth.currentUser == null) {
        throw ('No user currently logged in');
      }

      final projectsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('projects')
          .orderBy('created_at', descending: true)
          .get();

      final fetchedProjects = projectsSnapshot.docs
          .map((doc) => Project.fromJson(doc.data()))
          .toList();

      if (_projects != fetchedProjects) {
        _projects = fetchedProjects;
        notifyListeners();
      }

      if (projectName != null) {
        final project = _projects.firstWhere((p) => p.name == projectName,
            orElse: () => Project());
        if (project.id.isNotEmpty) {
          setProjectProvider(project);
        }
      }
    } catch (error) {
      throw FirebaseException(plugin: error.toString());
    }
  }

  Future<void> updateResource(String projectId, Resource resource) async {
    try {
      if (_auth.currentUser == null) {
        throw ('No user currently logged in');
      }

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('projects')
          .doc(projectId)
          .collection(
              resource.resourceType == ResourceType.data ? 'data' : 'models')
          .doc(resource.id);

      await docRef.update(resource.toJson());
    } catch (error) {
      print('Error updating resource: $error');
      throw FirebaseException(plugin: error.toString());
    }
  }

  Future<void> deleteResource(String projectId, Resource resource) async {
    try {
      if (_auth.currentUser == null) {
        throw ('No user currently logged in');
      }

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('projects')
          .doc(projectId);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users/${_auth.currentUser?.uid}/projects/$projectId');

      final collection =
          resource.resourceType == ResourceType.data ? 'data' : 'models';
      final resourceDocRef = docRef.collection(collection).doc(resource.id);
      await resourceDocRef.delete();

      final resourceStorageRef = storageRef.child('$collection/${resource.id}');
      await resourceStorageRef.delete();

      print('Successfully deleted resource');
    } catch (error) {
      print('Error deleting resource: $error');
      throw FirebaseException(plugin: error.toString());
    }
  }

  Future<void> fetchResources(String projectId) async {
    try {
      if (_auth.currentUser == null) {
        throw ('No user currently logged in');
      }

      final dataSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('projects')
          .doc(projectId)
          .collection('data')
          .get();

      final modelsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('projects')
          .doc(projectId)
          .collection('models')
          .get();

      final newData =
          dataSnapshot.docs.map((doc) => Data.fromJson(doc.data())).toList();

      final newModels =
          modelsSnapshot.docs.map((doc) => Model.fromJson(doc.data())).toList();

      if (_projectProvider.data != newData ||
          _projectProvider.models != newModels) {
        _projectProvider.data = newData;
        _projectProvider.models = newModels;
        notifyListeners();
      }
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (error) {
      throw FirebaseAuthException(code: error.toString());
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No user found for that email.';
        case 'invalid-credential':
          throw 'Invalid Credentials';
        case 'too-many-requests':
          throw 'Too many requests! Try again later. If issue persists, contact support.';
        default:
          throw 'An error occurred: ${e.message} - code: ${e.code}';
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw 'An error occurred: ${e.message} - code: ${e.code}';
    }
  }

  Future<void> reauthenticateWithCredential(String password) async {
    try {
      if (_auth.currentUser == null || _auth.currentUser!.email == null) {
        throw ('User or email not found');
      }

      final email = _auth.currentUser!.email!;
      final credential =
          EmailAuthProvider.credential(email: email, password: password);
      await _auth.currentUser?.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          throw 'The provided credentials are invalid.';
        default:
          throw 'An error occurred: ${e.message} - code: ${e.code}';
      }
    }
  }

  Future<void> refreshUserToken() async {
    _auth.userChanges();
  }

  Future<void> resetPassword() async {
    try {
      if (_auth.currentUser == null || _auth.currentUser!.email == null) {
        throw ('User or email not found');
      }

      final email = _auth.currentUser!.email!;
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw 'An error occurred: ${e.message}';
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      throw 'An error occurred: ${e.message} - code: ${e.code}';
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw 'An error occurred: ${e.message} - code: ${e.code}';
    }
  }
}
