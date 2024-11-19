import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/data/firebase_auth_repo.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_states.dart';
import 'package:social_media_app/features/auth/presentation/pages/auth_page.dart';
import 'package:social_media_app/features/chat/data/firebase_chat_repo.dart';
import 'package:social_media_app/features/chat/presentation/chat_list/chat_list_cubit/chat_list_cubit.dart';
import 'package:social_media_app/features/chat/presentation/user_chat/user_chat_cubit/user_chat_cubit.dart';
import 'package:social_media_app/features/home/presentation/pages/home_page.dart';
import 'package:social_media_app/features/post/data/repository/firebase_post_repo.dart';
import 'package:social_media_app/features/post/presentation/cubit/post_cubit.dart';
import 'package:social_media_app/features/profile/data/firebase_profile_repo.dart';
import 'package:social_media_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:social_media_app/features/search/data/firebase_search_repo.dart';
import 'package:social_media_app/features/search/presentation/cubit/search_cubit.dart';
import 'package:social_media_app/storage/data/firebase_storage_repo.dart';
import 'package:social_media_app/themes/theme_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseAuthRepo = FirebaseAuthRepo();
    final firebaseProfileRepo = FirebaseProfileRepo();
    final firebaseStorageRepo = FirebaseStorageRepo();
    final firebasePostRepo = FirebasePostRepo();
    final firebaseSearchRepo = FirebaseSearchRepo();
    final firebaseChatRepo = FirebaseChatRepo();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            profileRepo: firebaseProfileRepo,
            storageRepo: firebaseStorageRepo,
          ),
        ),
        BlocProvider<PostCubit>(
          create: (context) => PostCubit(
            postRepo: firebasePostRepo,
            storageRepo: firebaseStorageRepo,
          ),
        ),
        BlocProvider<SearchCubit>(
          create: (context) => SearchCubit(searchRepo: firebaseSearchRepo),
        ),
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        BlocProvider<ChatListCubit>(
          create: (context) => ChatListCubit(
            chatRepo: firebaseChatRepo,
            profileRepo: firebaseProfileRepo,
          ),
        ),
        BlocProvider<UserChatCubit>(
          create: (context) => UserChatCubit(chatRepo: firebaseChatRepo),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, currentTheme) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: currentTheme,
          home: BlocConsumer<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (authState is Unauthenticated) {
                return const AuthPage();
              }
              if (authState is Authenticated) {
                return const HomePage();
              } else {
                return _loading();
              }
            },
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _loading() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
