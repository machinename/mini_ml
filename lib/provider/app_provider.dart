import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mini_ml/models/data.dart';
import 'package:mini_ml/models/model.dart';
import 'package:mini_ml/models/project.dart';
import 'package:mini_ml/models/resource.dart';
import 'package:mini_ml/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  // Provider Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  late SharedPreferences _prefs;
  Project _projectProvider = Project();
  num _userStorageInMegaBytes = 0;

  // Provider Accessors
  FirebaseAuth get auth => _auth;
  bool get isLoading => _isLoading;
  Project get projectProvider => _projectProvider;
  num get userStorageInMegaBytes => _userStorageInMegaBytes;

  // Lists Instances
  List<Project> _projects = [];
  // List Accessors
  List<Project> get projects => _projects;

  void setIsLoading(bool isloading) {
    _isLoading = isloading;
    notifyListeners();
  }

  Future<void> setProjectProvider(Project project) async {
    try {
      _projectProvider = project;
      _prefs = await SharedPreferences.getInstance();
      await _prefs.setString('recent_project', project.name);
      notifyListeners();
      print('Successfully set provider project: ${_projectProvider.name}');
      await fetchResources(project.id);
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  Future<void> setProjectProviderEmpty() async {
    try {
      _projectProvider = Project();
      _prefs = await SharedPreferences.getInstance();
      await _prefs.setString('recent_project', '');
      notifyListeners();
    } catch (error) {
      throw Exception(error.toString());
    }
  }



  Future<void> fetchAppData() async {
    try {
      if (_auth.currentUser != null) {
        await fetchProjects();
        await fetchPreferences();
        await fetchUserStorage();
      } else {
        print('User Not Logged In');
      }
    } catch (error) {
      throw Exception(error.toString());
    }
  }


Future<void> fetchUserStorage() async {
  try {
    if (_auth.currentUser != null) {
      APIServices().fetchUserStorage(_auth.currentUser!).then((value) {
        var userStorage = value;
        
        if(userStorage != null) {
           _userStorageInMegaBytes = userStorage;
        }
      });
    } else {
      throw ('No user currently logged in');
    }
  } catch (error) {
    print('Error fetching user storage: $error');
    throw FirebaseException(plugin: 'firebase_storage', message: error.toString());
  } finally {
    notifyListeners();
  }
}
  Future<void> fetchPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    String? recentProject = _prefs.getString('recent_project');

    if (recentProject != null) {
      for (Project project in _projects) {
        if (project.name == recentProject) {
          setProjectProvider(project);
          return;
        }
      }
      print('Provider project empty');
    } else {
      print('No Recent Projects');
    }
  }

  Future<bool> checkForExisitingProject(Project project) async {
    try {
      if (_auth.currentUser != null) {
        QuerySnapshot existingProjects = await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .collection('projects')
            .where('name', isEqualTo: project.name.toLowerCase())
            .get();

        if (existingProjects.docs.isNotEmpty) {
          return true;
        }
        return false;
      } else {
        throw ('No user currently logged in');
      }
    } catch (error) {
      print('Error creating project on database: $error');
      throw FirebaseException(plugin: error.toString());
    }
  }

  Future<bool> checkForExisitingResource(
      String projectId, Resource resource) async {
    try {
      if (_auth.currentUser != null) {
        if (resource.resourceType == ResourceType.data) {
          QuerySnapshot existingDataSet = await FirebaseFirestore.instance
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .collection('projects')
              .doc(projectId)
              .collection('data')
              .where('name', isEqualTo: resource.name.toLowerCase())
              .get();

          if (existingDataSet.docs.isNotEmpty) {
            return true;
          }
        } else {
          QuerySnapshot existingModel = await FirebaseFirestore.instance
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .collection('projects')
              .doc(projectId)
              .collection('models')
              .where('name', isEqualTo: resource.name.toLowerCase())
              .get();

          if (existingModel.docs.isNotEmpty) {
            return true;
          }
        }
        return false;
      } else {
        throw ('No user currently logged in');
      }
    } catch (error) {
      print('Error creating resource on database: $error');
      throw FirebaseException(plugin: error.toString());
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception("User is not valid");
      }
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('projects')
          .doc(project.id);

      var projectJson = project.toJson();
      await docRef.update(projectJson);
    } catch (error) {
      throw FirebaseException(plugin: error.toString());
    }
  }

  Future<void> deleteProject(Project project) async {
    try {
      if (_auth.currentUser != null) {
        for (Data data in project.data) {
          await deleteResource(project.id, data);
        }

        for (Model model in project.models) {
          await deleteResource(project.id, model);
        }
      } else {
        throw ('No user currently logged in');
      }

      final DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('projects')
          .doc(project.id);
      docRef.delete();
    } catch (error) {
      print('Error deleting project from database: $error');
      throw FirebaseException(plugin: error.toString());
    }
  }

  Future<void> fetchProjects({String? projectName}) async {
    try {
      if (_auth.currentUser != null) {
        QuerySnapshot projects = await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .collection('projects')
            .orderBy('created_at', descending: true)
            .get();

        if (_projects !=
            projects.docs
                .map((doc) =>
                    Project.fromJson(doc.data() as Map<String, dynamic>))
                .toList()) {
          _projects = projects.docs
              .map(
                  (doc) => Project.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
        } else {
          print('No new projects to fetch');
        }

        if (projectName != null) {
          for (Project project in _projects) {
            if (project.name == projectName) {
              setProjectProvider(project);
              return;
            }
          }
        }
        print('Successfully fetched projects from database');
      }
    } catch (error) {
      throw FirebaseException(plugin: error.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateResource(String projectId, Resource resource) async {
    try {
      if (_auth.currentUser != null) {
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .collection('projects')
            .doc(projectId);

        if (resource.resourceType == ResourceType.data) {
          docRef = docRef.collection('data').doc(resource.id);
          await docRef.update(resource.toJson());
          print('Successfully updated data set on database');
        } else if (resource.resourceType == ResourceType.model) {
          docRef = docRef.collection('models').doc(resource.id);
          await docRef.update(resource.toJson());
          print('Successfully updated model on database');
        } else {
          throw ('Invalid Resource Type');
        }
      }
    } catch (error) {
      print('Error creating project on database: $error');
      throw FirebaseException(plugin: error.toString());
    }
  }

  Future<void> deleteResource(String projectId, Resource resource) async {
    try {
      if (_auth.currentUser != null) {
        final DocumentReference docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .collection('projects')
            .doc(projectId);

        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('users/${_auth.currentUser?.uid}/projects/$projectId');

        if (resource.resourceType == ResourceType.data) {
          var dataDocRef = docRef.collection('data').doc(resource.id);
          await dataDocRef.delete();

          var dataStorageRef = storageRef.child('data/${resource.id}');
          await dataStorageRef.delete();

          print('Successfully deleted data from database');
        } else {
          var modelDocRef = docRef.collection('models').doc(resource.id);
          await modelDocRef.delete();

          var modelStorageRef = storageRef.child('models/${resource.id}');
          await modelStorageRef.delete();

          print('Successfully deleted model from database');
        }
      }
    } catch (error) {
      print('Error deleting resource from database: $error');
      throw FirebaseException(plugin: error.toString());
    }
  }

  Future<void> deleteDataFromAssociatedModels(String projectId, Data data) async {
    try {
      if (_auth.currentUser != null) {
        final DocumentReference docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .collection('projects')
            .doc(projectId);

        for (Model model in _projectProvider.models) {
          if (model.dataId == data.id) {
            var newModel = model;
            newModel.dataId = '';
            docRef.collection('models').doc(model.id).update(newModel.toJson());
            print('Successfully deleted data from associated models');
          }
        }
      }
    } catch (error) {
      print('Error deleting resource from database: $error');
      throw FirebaseException(plugin: error.toString());
    }
  }

  Future<void> fetchResources(String projectId) async {
    try {
      if (_auth.currentUser != null) {
        QuerySnapshot data = await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .collection('projects')
            .doc(projectId)
            .collection('data')
            .get();

        QuerySnapshot models = await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .collection('projects')
            .doc(projectId)
            .collection('models')
            .get();

        if (_projectProvider.data ==
                data.docs
                    .map((doc) =>
                        Data.fromJson(doc.data() as Map<String, dynamic>))
                    .toList() &&
            _projectProvider.models ==
                models.docs
                    .map((doc) =>
                        Model.fromJson(doc.data() as Map<String, dynamic>))
                    .toList()) {
          return;
        }

        _projectProvider.data = data.docs
            .map((doc) => Data.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        _projectProvider.models = models.docs
            .map((doc) => Model.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        print(
            'Successfully fetched resources for project: ${_projectProvider.name}');
      } else {
        throw ('No user currently logged in');
      }
    } catch (error) {
      throw Exception(error.toString());
    } finally {
      notifyListeners();
    }
  }

  Map<String, dynamic> getDataVariables(String dataId) {
    try {
      for (Data data in _projectProvider.data) {
        if (data.id == dataId) {
          return data.variables;
        }
      }
      throw ('Data Set Not Found');
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
    } finally {
      notifyListeners();
    }
  }

  // on FirebaseAuthException catch (e) {
  //     if (e.code == 'weak-password') {
  //       message = 'The password provided is too weak.';
  //     } else if (e.code == 'email-already-in-use') {
  //       message = 'An account already exists with that email.';
  //     }
  //     Fluttertoast.showToast(
  //       msg: message,
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.SNACKBAR,
  //       backgroundColor: Colors.black54,
  //       textColor: Colors.white,
  //       fontSize: 14.0,
  //     );
  //   } catch (e) {
  //     Fluttertoast.showToast(
  //       msg: "Failed: $e",
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.SNACKBAR,
  //       backgroundColor: Colors.black54,
  //       textColor: Colors.white,
  //       fontSize: 14.0,
  //     );
  //   }
  // }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No user found for that email.';
        case 'wrong-password':
          throw 'Wrong password provided for that user.';
        case 'too-many-requests':
          throw 'Too many requests! Try again later. If issue persists, contact support.';
        default:
          throw 'An error occurred: ${e.message} - code: ${e.code}';
      }
    } catch (error) {
      throw 'An unexpected error occurred: ${error.toString()}';
    } finally {
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw 'An error occurred: ${e.message} - code: ${e.code}';
    } catch (error) {
      throw 'An unexpected error occurred: ${error.toString()}';
    } finally {
      notifyListeners();
    }
  }

  Future<void> reauthenticateWithCredential(String password) async {
    try {
      if (_auth.currentUser == null) {
        throw ('User not found');
      }
      if (_auth.currentUser!.email == null) {
        throw ('Email not found');
      }
      String email = _auth.currentUser!.email!;
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: password);
      await _auth.currentUser?.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          throw 'The provided credentials are invalid.';
        default:
          throw 'An error occurred: ${e.message} - code: ${e.code}';
      }
    } catch (error) {
      throw 'An unexpected error occurred: ${error.toString()}';
    } finally {
      notifyListeners();
    }
  }

  Future<void> resetPassword() async {
    try {
      if (_auth.currentUser == null) {
        throw ('User not found');
      }

      if (_auth.currentUser!.email == null) {
        throw ('Email not found');
      }

      String email = _auth.currentUser!.email!;
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw 'An error occurred: ${e.message}';
    } catch (error) {
      throw 'An unexpected error occurred: ${error.toString()}';
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (_auth.currentUser != null) {
        print('Deleting Account');
        await _auth.currentUser!.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw 'An error occurred: ${e.message} - code: ${e.code}';
    } catch (error) {
      throw 'An unexpected error occurred: ${error.toString()}';
    } finally {
      notifyListeners();
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw 'An error occurred: ${e.message} - code: ${e.code}';
    } catch (error) {
      throw 'An unexpected error occurred: ${error.toString()}';
    } finally {
      notifyListeners();
    }
  }
}
