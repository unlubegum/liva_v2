/// PowerSync Schema Definition for Liva V2
/// 
/// This file defines all tables that will be synced with Supabase.
/// Each table mirrors the Supabase schema defined in setup_database.sql
library;

import 'package:powersync/powersync.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// TABLE DEFINITIONS
/// ─────────────────────────────────────────────────────────────────────────────

const familiesTable = Table('families', [
  Column.text('name'),
  Column.text('invite_code'),
  Column.text('created_at'),
  Column.text('updated_at'),
]);

const profilesTable = Table('profiles', [
  Column.text('family_id'),
  Column.text('email'),
  Column.text('full_name'),
  Column.text('avatar_url'),
  Column.text('role'),
  Column.integer('module_family'),
  Column.integer('module_home'),
  Column.integer('module_car'),
  Column.integer('module_pets'),
  Column.integer('module_travel'),
  Column.integer('module_podcast'),
  Column.integer('module_budget'),
  Column.integer('module_fitness'),
  Column.integer('module_cycle'),
  Column.integer('module_pregnancy'),
  Column.integer('module_fashion'),
  Column.text('created_at'),
  Column.text('updated_at'),
]);

const familyTasksTable = Table('family_tasks', [
  Column.text('family_id'),
  Column.text('assigned_to_id'),
  Column.text('title'),
  Column.text('description'),
  Column.integer('is_completed'),
  Column.text('due_date'),
  Column.text('created_at'),
  Column.text('updated_at'),
]);

const shoppingItemsTable = Table('shopping_items', [
  Column.text('family_id'),
  Column.text('added_by_id'),
  Column.text('name'),
  Column.integer('quantity'),
  Column.integer('is_purchased'),
  Column.text('created_at'),
  Column.text('updated_at'),
]);

const familyWallTable = Table('family_wall', [
  Column.text('family_id'),
  Column.text('content'),
  Column.text('author_id'),
  Column.text('created_at'),
]);

const homeBillsTable = Table('home_bills', [
  Column.text('family_id'),
  Column.text('name'),
  Column.real('amount'),
  Column.text('due_date'),
  Column.text('status'),
  Column.integer('is_recurring'),
  Column.integer('recurrence_months'),
  Column.text('created_at'),
  Column.text('updated_at'),
]);

const homeAssetsTable = Table('home_assets', [
  Column.text('family_id'),
  Column.text('name'),
  Column.text('brand'),
  Column.text('model'),
  Column.text('purchase_date'),
  Column.text('warranty_end_date'),
  Column.text('notes'),
  Column.text('created_at'),
  Column.text('updated_at'),
]);

const petsTable = Table('pets', [
  Column.text('family_id'),
  Column.text('name'),
  Column.text('type'),
  Column.text('breed'),
  Column.text('birth_date'),
  Column.real('weight_kg'),
  Column.text('avatar_url'),
  Column.text('allergies'), // JSON array as text
  Column.text('notes'),
  Column.text('created_at'),
  Column.text('updated_at'),
]);

const petVaccinesTable = Table('pet_vaccines', [
  Column.text('pet_id'),
  Column.text('name'),
  Column.text('administered_date'),
  Column.text('next_due_date'),
  Column.text('vet_name'),
  Column.text('notes'),
  Column.text('created_at'),
  Column.text('updated_at'),
]);

const tripsTable = Table('trips', [
  Column.text('family_id'),
  Column.text('destination'),
  Column.text('emoji'),
  Column.text('start_date'),
  Column.text('end_date'),
  Column.text('accent_color_hex'),
  Column.text('notes'),
  Column.text('created_at'),
  Column.text('updated_at'),
]);

const packingItemsTable = Table('packing_items', [
  Column.text('trip_id'),
  Column.text('name'),
  Column.text('category'),
  Column.integer('is_packed'),
  Column.integer('is_ai_generated'),
  Column.text('created_at'),
  Column.text('updated_at'),
]);

const transactionsTable = Table('transactions', [
  Column.text('family_id'),
  Column.text('user_id'),
  Column.text('title'),
  Column.real('amount'),
  Column.text('category'),
  Column.integer('is_expense'),
  Column.text('transaction_date'),
  Column.text('notes'),
  Column.text('created_at'),
  Column.text('updated_at'),
]);

/// ─────────────────────────────────────────────────────────────────────────────
/// SCHEMA EXPORT
/// ─────────────────────────────────────────────────────────────────────────────

final schema = Schema([
  familiesTable,
  profilesTable,
  familyTasksTable,
  shoppingItemsTable,
  familyWallTable,
  homeBillsTable,
  homeAssetsTable,
  petsTable,
  petVaccinesTable,
  tripsTable,
  packingItemsTable,
  transactionsTable,
]);
