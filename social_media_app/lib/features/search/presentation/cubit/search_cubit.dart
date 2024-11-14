import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/search/domain/search_repo.dart';
import 'package:social_media_app/features/search/presentation/cubit/search_states.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo searchRepo;

  SearchCubit({required this.searchRepo}) : super(SearchInitial());

  Future<void> searchUsers(String query) async {
    try {
      if (query.isEmpty) {
        emit(SearchInitial());
        return;
      } else {
        emit(SearchLoading());
        final users = await searchRepo.searchUsers(query);
        emit(SearchLoaded(users));
      }
    } catch (e) {
      throw Exception('Error fetching search results: $e');
    }
  }
}
