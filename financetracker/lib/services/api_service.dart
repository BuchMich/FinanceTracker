import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import '../models/savings_goal.dart';

class ApiService {
  // Für Android Emulator: 10.0.2.2, für Windows/Web: localhost
  static const String baseUrl = 'http://10.0.2.2:3000';

  static Future<List<Transaction>> getTransactions() async {
    final response = await http.get(Uri.parse('$baseUrl/transactions'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Transaction.fromJson(json)).toList();
    }
    throw Exception('Fehler beim Laden der Transaktionen');
  }

  static Future<Transaction> addTransaction(Transaction transaction) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(transaction.toJson()),
    );
    if (response.statusCode == 201) {
      return Transaction.fromJson(json.decode(response.body));
    }
    throw Exception('Fehler beim Erstellen der Transaktion');
  }

  static Future<Transaction> updateTransaction(Transaction transaction) async {
    final response = await http.put(
      Uri.parse('$baseUrl/transactions/${transaction.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(transaction.toJson()),
    );
    if (response.statusCode == 200) {
      return Transaction.fromJson(json.decode(response.body));
    }
    throw Exception('Fehler beim Aktualisieren der Transaktion');
  }

  static Future<void> deleteTransaction(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/transactions/$id'));
    if (response.statusCode != 200) {
      throw Exception('Fehler beim Löschen der Transaktion');
    }
  }

  // ==================== SAVINGS GOALS ====================

  static Future<List<SavingsGoal>> getSavingsGoals() async {
    final response = await http.get(Uri.parse('$baseUrl/savings-goals'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SavingsGoal.fromJson(json)).toList();
    }
    throw Exception('Fehler beim Laden der Sparziele');
  }

  static Future<SavingsGoal> addSavingsGoal(SavingsGoal goal) async {
    final response = await http.post(
      Uri.parse('$baseUrl/savings-goals'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(goal.toJson()),
    );
    if (response.statusCode == 201) {
      return SavingsGoal.fromJson(json.decode(response.body));
    }
    throw Exception('Fehler beim Erstellen des Sparziels');
  }

  static Future<SavingsGoal> updateSavingsGoal(SavingsGoal goal) async {
    final response = await http.put(
      Uri.parse('$baseUrl/savings-goals/${goal.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(goal.toJson()),
    );
    if (response.statusCode == 200) {
      return SavingsGoal.fromJson(json.decode(response.body));
    }
    throw Exception('Fehler beim Aktualisieren des Sparziels');
  }

  static Future<void> deleteSavingsGoal(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/savings-goals/$id'));
    if (response.statusCode != 200) {
      throw Exception('Fehler beim Löschen des Sparziels');
    }
  }
}
