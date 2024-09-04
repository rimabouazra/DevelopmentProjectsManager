import 'dart:convert';

import 'package:flutter/material.dart';

enum Role {
  Developer,
  Manager,
  Administrator,
}

class User extends ChangeNotifier {
  String idUtilisateur;
  String nomUtilisateur;
  String email;
  String? token;
  String? motDePasse;
  Role role;
  User? currentUser;

  User({
    required this.idUtilisateur,
    required this.nomUtilisateur,
    required this.email,
    this.token,
    this.motDePasse,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': nomUtilisateur,
      'email': email,
      'token': token,
      'password': motDePasse,
      'role': role.toString().split('.').last.toLowerCase(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    Role role;
    String roleString = json['role'].toString().toLowerCase();

    /*if (json['role'] is String) {
      role = Role.values.firstWhere(
        (r) =>
            r.toString().split('.').last.toLowerCase() ==
            json['role'].toLowerCase(),
        orElse: () => Role.Developer,
      );
    } else {
      int roleIndex = json['role'] ?? 0;
      role = Role.values[roleIndex.clamp(0, Role.values.length - 1)];
    }*/
    switch (roleString) {
    case 'manager':
      role = Role.Manager;
      break;
    case 'administrator':
      role = Role.Administrator;
      break;
    case 'developer':
      role = Role.Developer;
      break;
    default:
      print("Unknown role: $roleString, defaulting to Developer");
      role = Role.Developer;
      break;
  }
  print("Role parsed from JSON: $roleString, Mapped to: $role");

  return User(
    idUtilisateur: json['_id'] ?? '',
    nomUtilisateur: json['name'] ?? '',
    email: json['email'] ?? '',
    motDePasse: json['password'] ?? '',
    role: role,
    token: json['token'],
  );
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  String toJsonString() => json.encode(toMap());

  //permissions
  bool canCreateProject() {
    return role == Role.Manager;
  }

  bool canManageUsers() {
    return role == Role.Administrator;
  }

  bool canModifyProject() {
    return role == Role.Manager || role == Role.Administrator;
  }
}
