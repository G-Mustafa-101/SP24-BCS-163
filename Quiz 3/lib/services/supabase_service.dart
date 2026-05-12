import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/submission.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<void> createSubmission(Submission submission) async {
    await _client.from('submissions').insert(submission.toJson());
  }

  Future<List<Submission>> fetchSubmissions() async {
    final response = await _client
        .from('submissions')
        .select()
        .order('createdat', ascending: false);
    
    return (response as List).map((json) => Submission.fromJson(json)).toList();
  }

  Future<void> updateSubmission(String id, Submission submission) async {
    await _client
        .from('submissions')
        .update(submission.toJson())
        .eq('id', id);
  }

  Future<void> deleteSubmission(String id) async {
    await _client.from('submissions').delete().eq('id', id);
  }
}
