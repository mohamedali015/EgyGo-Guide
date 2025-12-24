import 'dart:io';
import 'package:egy_go_guide/features/guide_application/data/repos/guide_application_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'apply_guide_state.dart';

class ApplyGuideCubit extends Cubit<ApplyGuideState> {
  final GuideApplicationRepo repo;

  ApplyGuideCubit(this.repo) : super(ApplyGuideInitial());

  static ApplyGuideCubit get(context) => BlocProvider.of(context);

  bool isLicensed = false;
  File? idDocument;
  File? tourismCard;
  File? photo;
  File? englishCertificate;

  List<String> selectedLanguages = [];
  TextEditingController pricePerHourController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  final List<String> availableLanguages = [
    'English',
    'Arabic',
    'German',
    'Spanish',
    'French',
    'Italian',
    'Chinese',
    'Japanese',
    'Russian',
    'Portuguese',
    'Turkish',
    'Korean',
    'Dutch',
    'Swedish',
    'Polish',
    'Greek',
  ];

  void toggleLanguage(String language) {
    if (selectedLanguages.contains(language)) {
      selectedLanguages.remove(language);
    } else {
      selectedLanguages.add(language);
    }
    emit(ApplyGuideToggle());
  }

  void toggleLicensed() {
    isLicensed = !isLicensed;
    if (!isLicensed) {
      tourismCard = null;
    }
    emit(ApplyGuideToggle());
  }

  Future<void> pickIdDocument() async {
    final XFile? result = await _picker.pickImage(source: ImageSource.gallery);

    if (result != null) {
      idDocument = File(result.path);
      emit(ApplyGuideToggle());
    }
  }

  Future<void> pickTourismCard() async {
    final XFile? result = await _picker.pickImage(source: ImageSource.gallery);

    if (result != null) {
      tourismCard = File(result.path);
      emit(ApplyGuideToggle());
    }
  }

  Future<void> pickPhoto() async {
    final XFile? result = await _picker.pickImage(source: ImageSource.gallery);

    if (result != null) {
      photo = File(result.path);
      emit(ApplyGuideToggle());
    }
  }

  Future<void> pickEnglishCertificate() async {
    final XFile? result = await _picker.pickImage(source: ImageSource.gallery);

    if (result != null) {
      englishCertificate = File(result.path);
      emit(ApplyGuideToggle());
    }
  }

  void applyAsGuide() async {
    if (idDocument == null) {
      emit(ApplyGuideError(error: 'National ID or Passport is required'));
      emit(ApplyGuideInitial());
      return;
    }

    if (photo == null) {
      emit(ApplyGuideError(error: 'Profile photo is required'));
      emit(ApplyGuideInitial());
      return;
    }

    if (isLicensed && tourismCard == null) {
      emit(ApplyGuideError(error: 'Tourism license card is required'));
      emit(ApplyGuideInitial());
      return;
    }

    if (selectedLanguages.isEmpty) {
      emit(ApplyGuideError(error: 'Please select at least one language'));
      emit(ApplyGuideInitial());
      return;
    }

    if (pricePerHourController.text.isEmpty) {
      emit(ApplyGuideError(error: 'Price per hour is required'));
      emit(ApplyGuideInitial());
      return;
    }

    final pricePerHour = double.tryParse(pricePerHourController.text);
    if (pricePerHour == null || pricePerHour <= 0) {
      emit(ApplyGuideError(error: 'Please enter a valid price per hour'));
      emit(ApplyGuideInitial());
      return;
    }

    if (bioController.text.trim().isEmpty) {
      emit(ApplyGuideError(error: 'Bio is required'));
      emit(ApplyGuideInitial());
      return;
    }

    emit(ApplyGuideLoading());

    var result = await repo.applyAsGuide(
      idDocument: idDocument!.path,
      photo: photo!.path,
      isLicensed: isLicensed.toString(),
      languages: selectedLanguages,
      pricePerHour: pricePerHour.toString(),
      bio: bioController.text.trim(),
      tourismCard: tourismCard?.path,
      englishCertificate: englishCertificate?.path,
    );

    result.fold(
      (error) => emit(ApplyGuideError(error: error)),
      (message) => emit(ApplyGuideSuccess(message: message)),
    );
  }

  @override
  Future<void> close() {
    pricePerHourController.dispose();
    bioController.dispose();
    return super.close();
  }
}
