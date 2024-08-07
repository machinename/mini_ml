import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mini_ml/models/model.dart';
import 'package:mini_ml/models/project.dart';
import 'package:mini_ml/models/resource.dart';
import 'package:pointycastle/export.dart';
import 'package:encrypt/encrypt.dart' as encrypt_package;
import 'package:http/http.dart' as http;

class APIServices {
  // Base URL of the API endpoints.
  // For development use, uncomment the local server URL and comment out the production URL.
  // final String _baseUrl = "https://mini-ml.uc.r.appspot.com";
  final String _baseUrl = 'http://192.168.1.192:8080';

  // Secure random key and initialization vector for AES encryption.
  static final _key = encrypt_package.Key.fromSecureRandom(32);
  static final _iv = encrypt_package.IV.fromSecureRandom(16);
  static final _encrypter = encrypt_package.Encrypter(
    encrypt_package.AES(_key, mode: encrypt_package.AESMode.cbc),
  );

  /// Fetches the server's RSA public key.
  ///
  /// [user] - The authenticated Firebase user.
  ///
  /// Returns the server's RSA public key as [RSAPublicKey].
  Future<RSAPublicKey> _fetchServerPublicKey(User user) async {
    try {
      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/fetch_server_public_key'),
        headers: {'Authorization': 'Bearer $idToken'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final serverPublicKey = jsonDecode(response.body)['server_public_key'];
        final parser = encrypt_package.RSAKeyParser();
        return parser.parse(serverPublicKey) as RSAPublicKey;
      } else {
        throw Exception('Failed to fetch server public key: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error fetching server public key: ${error.toString()}');
    }
  }

  /// Encrypts plaintext using RSA with the provided public key.
  ///
  /// [plaintext] - The text to encrypt.
  /// [publicKey] - The RSA public key used for encryption.
  ///
  /// Returns the encrypted text as a base64 encoded string.
  String _rsaEncrypt(String plaintext, RSAPublicKey publicKey) {
    final encryptor = OAEPEncoding(
      RSAEngine(),
    )..init(
        true,
        PublicKeyParameter<RSAPublicKey>(publicKey),
      );
    final encryptedBytes = encryptor.process(
      utf8.encode(plaintext),
    );
    return base64.encode(encryptedBytes);
  }

  /// Creates a new resource on the server.
  ///
  /// [projectId] - The ID of the project to which the resource belongs.
  /// [resource] - The resource to create.
  /// [user] - The authenticated Firebase user.
  /// [dataPath] - Optional path to a file containing data to encrypt and send with the resource.
  Future<void> createResource(String projectId, Resource resource, User user,
      {String? dataPath}) async {
    try {
      dynamic data;
      dynamic encryptedData;

      final serverPublicKey = await _fetchServerPublicKey(user);
      final resourceJson = json.encode(resource.toJson());

      // Encrypt data if a data path is provided.
      if (resource.resourceType.toString() == 'ResourceType.data') {
        if (dataPath == null) {
          throw Exception('Data Path Not Provided');
        }
        data = await File(dataPath).readAsString();
        encryptedData = _encrypter.encrypt(data, iv: _iv);
      }

      // Encrypt the resource JSON.
      final encryptedResourceJson = _encrypter.encrypt(resourceJson, iv: _iv);

      // Encrypt AES key, IV, and other details with RSA.
      final encryptedIV = _rsaEncrypt(_iv.base64, serverPublicKey);
      final encryptedKey = _rsaEncrypt(_key.base64, serverPublicKey);
      final encryptedProjectId = _rsaEncrypt(projectId, serverPublicKey);
      final encryptedUserId = _rsaEncrypt(user.uid, serverPublicKey);

      final idToken = await user.getIdToken();

      final url = Uri.parse('$_baseUrl/create_resource');

      final Map<String, dynamic> body = {
        'iv': encryptedIV,
        'key': encryptedKey,
        'project_id': encryptedProjectId,
        'resource_json': encryptedResourceJson.base64,
        'user_id': encryptedUserId,
      };

      if (encryptedData != null) {
        body['data'] = encryptedData.base64;
      }

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 201) {
        throw Exception('Failed to create resource: ${response.body}');
      }
    } catch (error) {
      print(error.toString());
      throw Exception(
          'Error Creating Resource, If The Error Persists Contact Support');
    } finally {
      if (dataPath != null) {
        File(dataPath).delete();
      }
    }
  }

  /// Creates a new project on the server.
  ///
  /// [project] - The project to create.
  /// [user] - The authenticated Firebase user.
  /// [dataPath] - Optional path to a file containing data to encrypt and send with the project.
  Future<void> createProject(Project project, User user,
      {String? dataPath}) async {
    try {
      final serverPublicKey = await _fetchServerPublicKey(user);
      final projectJson = json.encode(project.toJson());
      final encryptedProjectJson = _encrypter.encrypt(projectJson, iv: _iv);
      final encryptedIV = _rsaEncrypt(_iv.base64, serverPublicKey);
      final encryptedKey = _rsaEncrypt(_key.base64, serverPublicKey);
      final encryptedUserId = _rsaEncrypt(user.uid, serverPublicKey);
      final idToken = await user.getIdToken();
      final url = Uri.parse('$_baseUrl/create_project');

      final Map<String, dynamic> body = {
        'iv': encryptedIV,
        'key': encryptedKey,
        'project_json': encryptedProjectJson.base64,
        'user_id': encryptedUserId,
      };

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 201) {
        throw Exception('Failed to create project: ${response.body}');
      }
    } catch (error) {
      print(error.toString());
      throw Exception(
          'Error Creating Project, If The Error Persists Contact Support');
    }
  }
}
