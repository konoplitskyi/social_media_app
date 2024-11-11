import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/presentation/components/my_textfield.dart';
import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_app/features/profile/presenation/cubit/profile_cubit.dart';
import 'package:social_media_app/features/profile/presenation/cubit/profile_states.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;

  const EditProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  PlatformFile? imagePickedFile;

  Uint8List? webImage;

  final bioTextController = TextEditingController();

  @override
  void dispose() {
    bioTextController.dispose();

    super.dispose();
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

  void updateProfile() async {
    final profileCubit = context.read<ProfileCubit>();

    final String uid = widget.user.uid;
    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final imageWebBytes = kIsWeb ? imagePickedFile?.bytes : null;
    final String? newBio = bioTextController.text.isNotEmpty
        ? bioTextController.text.trim()
        : null;

    if (imagePickedFile != null || newBio != null) {
      profileCubit.updateProfile(
        uid: uid,
        newBio: newBio,
        imageMobilePath: imageMobilePath,
        imageWebBytes: imageWebBytes,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 25),
                  Text('Uploading...'),
                ],
              ),
            ),
          );
        } else {
          return buildEditPage();
        }
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildEditPage() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          foregroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            IconButton(
              onPressed: updateProfile,
              icon: const Icon(Icons.upload),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              Center(
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child:

                      // display selected image for mobile
                      (!kIsWeb && imagePickedFile != null)
                          ? Image.file(
                              File(imagePickedFile!.path!),
                              fit: BoxFit.cover,
                            )
                          :
                          // display selected image for web
                          (kIsWeb && webImage != null)
                              ? Image.memory(
                                  webImage!,
                                  fit: BoxFit.cover,
                                )
                              :
                              // no image selected ->display existing profile pic
                              CachedNetworkImage(
                                  imageUrl: widget.user.profileImageUrl,

                                  // loading..
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),

                                  // error -> failed to load
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.person,
                                    size: 72,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),

                                  // loaded
                                  imageBuilder: (context, imageProvider) =>
                                      Image(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: MaterialButton(
                  onPressed: pickImage,
                  color: Colors.blue,
                  child: const Text('Pick Image'),
                ),
              ),
              const SizedBox(height: 25),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Bio'),
                ],
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: bioTextController,
                hintText: widget.user.bio,
                obscureText: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
