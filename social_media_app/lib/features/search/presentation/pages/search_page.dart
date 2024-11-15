import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/profile/presenation/components/user_tile.dart';
import 'package:social_media_app/features/search/presentation/cubit/search_cubit.dart';
import 'package:social_media_app/features/search/presentation/cubit/search_states.dart';
import 'package:social_media_app/responsive/constrained_scaffold.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  late final searchCubit = context.read<SearchCubit>();

  @override
  void initState() {
    searchController.addListener(onSearchChanged);
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged() {
    final query = searchController.text.trim();
    searchCubit.searchUsers(query);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search users...',
            helperStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchLoaded) {
            if (state.users.isEmpty) {
              return const Center(
                child: Text('No users found'),
              );
            }
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];

                return UserTile(user: user!);
              },
            );
          } else if (state is SearchLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is SearchError) {
            return Center(
              child: Text(state.message),
            );
          }

          return const Center(
            child: Text('Start searching for users...'),
          );
        },
      ),
    );
  }
}
