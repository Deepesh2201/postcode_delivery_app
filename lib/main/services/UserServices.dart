import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../main.dart';
import 'package:nb_utils/nb_utils.dart';
import '../models/LoginResponse.dart';
import '../utils/Constants.dart';
import 'BaseServices.dart';

class UserService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  UserService() {
    ref = fireStore.collection(USER_COLLECTION);
  }

  Future<void> updateUserStatus(Map data, String id) async {
    return ref!.doc(id).update(data as Map<String, Object?>);
  }

  Future<UserData> getUser({String? email}) {
    return ref!.where("email", isEqualTo: email).limit(1).get().then((value) {
      if (value.docs.length == 1) {
        return UserData.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw language.userNotFound;
      }
    });
  }

  Stream<List<UserData>> users({String? searchText}) {
    return ref!.where('caseSearch', arrayContains: searchText.validate().isEmpty ? null : searchText!.toLowerCase()).snapshots().map((x) {
      return x.docs.map((y) {
        return UserData.fromJson(y.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<UserData> userByEmail(String? email) async {
    return await ref!.where('email', isEqualTo: email).limit(1).get().then((value) {
      if (value.docs.isNotEmpty) {
        return UserData.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw language.userNotFound;
      }
    });
  }

  Stream<UserData> singleUser(String? id, {String? searchText}) {
    return ref!.where('uid', isEqualTo: id).limit(1).snapshots().map((event) {
      return UserData.fromJson(event.docs.first.data() as Map<String, dynamic>);
    });
  }

  Future<UserData> userByMobileNumber(String? phone) async {
    log("Phone $phone");
    return await ref!.where('phoneNumber', isEqualTo: phone).limit(1).get().then((value) {
      log(value);
      if (value.docs.isNotEmpty) {
        return UserData.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw language.userNotFound;
      }
    });
  }
}
