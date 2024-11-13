import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/domain/entities/app_user.dart';
import 'package:social_media_app/features/auth/presentation/components/my_textfield.dart';
import 'package:social_media_app/features/auth/presentation/components/show_message.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/post/domain/entittes/post.dart';
import 'package:social_media_app/features/post/presentation/cubit/post_cubit.dart';
import 'package:social_media_app/features/post/presentation/cubit/post_states.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  final TextEditingController textController = TextEditingController();
  PlatformFile? imagePickedFile;
  Uint8List? webImage;
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  @override
  void dispose() {
    textController.dispose();

    super.dispose();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;

        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  void uploadPost() {
    if (imagePickedFile == null || textController.text.isEmpty) {
      showMessage(
        context,
        message: 'Both image and caption are required',
      );
      return;
    }

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: textController.text,
      imageUrl: '',
      timestamp: DateTime.now(),
      likes: [],
    );

    final postCubit = context.read<PostCubit>();
    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: imagePickedFile?.bytes);
    } else {
      postCubit.createPost(newPost, imagePath: imagePickedFile?.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      listener: (context, state) {
        if (state is PostLoaded) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        print(state);

        if (state is PostsLoading || state is PostsUploading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return buildUploadPage();
        }
      },
    );
  }

  Widget buildUploadPage() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Post'),
          foregroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            IconButton(
              onPressed: uploadPost,
              icon: const Icon(Icons.upload),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (kIsWeb && webImage != null)
                Image.memory(
                  webImage!,
                ),
              if (!kIsWeb && imagePickedFile != null)
                Image.file(
                  File(
                    imagePickedFile!.path!,
                  ),
                ),
              MaterialButton(
                onPressed: pickImage,
                color: Colors.blue,
                child: const Text('Pick Image'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: MyTextField(
                  controller: textController,
                  hintText: 'Caption',
                  obscureText: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
