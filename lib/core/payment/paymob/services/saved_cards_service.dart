import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_card.dart';

/// Local-storage service for saved payment cards.
///
/// Cards are persisted as a JSON list in [SharedPreferences].  The service is
/// intentionally kept independent of any state-management library so it can be
/// reused across the project or replaced by a backend call later.
class SavedCardsService {
  static const _storageKey = 'paymob_saved_cards';

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Returns all saved cards, sorted newest-first.
  Future<List<SavedCard>> getSavedCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_storageKey);
      if (raw == null || raw.isEmpty) return [];

      final cards = raw
          .map((e) {
            try {
              return SavedCard.fromJson(
                  jsonDecode(e) as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<SavedCard>()
          .toList()
        ..sort((a, b) => b.savedAt.compareTo(a.savedAt));

      developer.log(
        'SavedCards → loaded ${cards.length} card(s)',
        name: 'SavedCards',
      );
      return cards;
    } catch (e) {
      developer.log('SavedCards → load error: $e', name: 'SavedCards');
      return [];
    }
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Persists a new card.  If a card with the same last4 + brand already
  /// exists the old entry is replaced (prevents duplicates from re-saving
  /// the same card).
  Future<void> saveCard(SavedCard card) async {
    final cards = await getSavedCards();

    // Remove duplicate (same last4 + brand + holder)
    cards.removeWhere(
      (c) =>
          c.last4 == card.last4 &&
          c.brand == card.brand &&
          c.holderName == card.holderName,
    );

    cards.insert(0, card); // newest first

    await _persist(cards);
    developer.log(
      'SavedCards → saved card •••• ${card.last4} (${card.brand})',
      name: 'SavedCards',
    );
  }

  /// Deletes a card by its local [id].
  Future<void> deleteCard(String id) async {
    final cards = await getSavedCards();
    cards.removeWhere((c) => c.id == id);
    await _persist(cards);
    developer.log('SavedCards → deleted card $id', name: 'SavedCards');
  }

  /// Removes all saved cards.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    developer.log('SavedCards → cleared all', name: 'SavedCards');
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _persist(List<SavedCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = cards.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }
}
