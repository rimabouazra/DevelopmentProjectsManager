
import 'dart:convert';

import 'package:flutter/material.dart';

enum Role {
  Developer,
  Manager,
  Administrator,
}

class User  extends ChangeNotifier {
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
      'role': role.index,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUtilisateur: json['_id']?? '' ,
      nomUtilisateur: json['name']?? '',
      email: json['email'] ?? '',
      motDePasse: json['password']?? '',
      role: Role.values[json['role'] ?? 0],
      token: json['token'],
    );
  }

  String toJson() => json.encode(toMap());

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
