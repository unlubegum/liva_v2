/// Supabase Configuration
///
/// Centralized configuration for Supabase and PowerSync.
library;

/// Supabase project URL
/// Format: https://<project-id>.supabase.co
const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://zskhtjuazzzwrxjzfyxi.supabase.co',
);

/// Supabase anonymous key
/// Get this from: Supabase Dashboard > Settings > API > anon/public key
/// TODO: Replace with your actual anon key from Supabase Dashboard
const supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpza2h0anVhenp6d3J4anpmeXhpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1ODQ4MzUsImV4cCI6MjA4NDE2MDgzNX0.kSFtg7trTK64WPidZrRrngDzq1yeFOONmXiiX3xgfnI',
);

/// PowerSync instance URL
/// Get this from: PowerSync Dashboard > Instance > URL
const powersyncUrl = String.fromEnvironment(
  'POWERSYNC_URL',
  defaultValue: 'https://696a881530605f245f02c910.powersync.journeyapps.com',
);

/// Check if we're using real credentials or placeholders
bool get isConfigured =>
    !supabaseAnonKey.contains('YOUR_SUPABASE_ANON_KEY');
