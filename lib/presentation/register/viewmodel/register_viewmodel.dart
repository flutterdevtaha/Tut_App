import 'dart:async';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter_app/app/functions.dart';
import 'package:flutter_app/domain/usecase/register_usecase/register_usecase.dart';
import 'package:flutter_app/domain/usecase/register_usecase/register_usecase_input.dart';
import 'package:flutter_app/presentation/base/base_viewmodel.dart';
import 'package:flutter_app/presentation/common/freezed_data_classes.dart';
import 'package:flutter_app/presentation/common/state_render/states/content_state.dart';
import 'package:flutter_app/presentation/common/state_render/states/error_state.dart';
import 'package:flutter_app/presentation/common/state_render/states/loading_state.dart';
import 'package:flutter_app/presentation/common/state_render/states/state_renderer_type.dart';
import 'package:flutter_app/presentation/register/viewmodel/register_viewmodel_inputs.dart';
import 'package:flutter_app/presentation/register/viewmodel/register_viewmodel_outputs.dart';
import 'package:flutter_app/presentation/resources/other_managers/strings_manager.dart';

class RegisterViewModel extends BaseViewModel
    with RegisterViewModelInputs, RegisterViewModelOutputs {
  final RegisterUseCase _registerUseCase;
  RegisterViewModel(this._registerUseCase);
  var registerObject = RegisterObject("", "", "", "", "", "");

  final StreamController _userNameController =
      StreamController<String>.broadcast();
  final StreamController _mobileNumberController =
      StreamController<String>.broadcast();
  final StreamController _emailController =
      StreamController<String>.broadcast();
  final StreamController _passwordController =
      StreamController<String>.broadcast();
  final StreamController _profilePictureController =
      StreamController<File>.broadcast();
  final StreamController _areAllInputsValidController =
      StreamController<void>.broadcast();

  @override
  void dispose() {
    super.dispose();
    _userNameController.close();
    _mobileNumberController.close();
    _emailController.close();
    _passwordController.close();
    _profilePictureController.close();
    _areAllInputsValidController.close();
  }

  @override
  void start() {
    // view model should tell view, please show content state
    inputState.add(ContentState());
  }

  @override
  register() async {
    inputState.add(
      LoadingState(stateRendererType: StateRendererType.popupLoadingState),
    );
    (await _registerUseCase.execute(
      RegisterUseCaseInput(
        registerObject.userName,
        registerObject.countryMobileCode,
        registerObject.mobileNumber,
        registerObject.email,
        registerObject.password,
        registerObject.profilePicture,
      ),
    ))
        .fold(
      (failure) {
        // left -> failure
        inputState.add(
          ErrorState(
            StateRendererType.popupErrorState,
            failure.message,
          ),
        );
        debugPrint("failure = ${failure.message}");
      },
      (data) {
        // right -> success (data)
        inputState.add(ContentState());
        debugPrint("data = ${data.customer?.name}");
      },
    );
  }

  @override
  Sink get inputEmail => _emailController.sink;
  @override
  Sink get inputMobileNumber => _mobileNumberController.sink;
  @override
  Sink get inputProfilePicture => _profilePictureController.sink;
  @override
  Sink get inputUserName => _userNameController.sink;
  @override
  Sink get inputPassword => _passwordController.sink;

  bool _isPasswordValid(String password) => password.length >= 6;
  bool _isMobileNumberValid(String mobileNumber) => mobileNumber.length >= 10;
  bool _isUserNameValid(String userName) => userName.length >= 8;

  @override
  Stream<String?> get outputErrorMobileNumber => outputIsMobileNumberValid.map(
        (isValid) => isValid ? null : AppStrings.mobileNumberInvalid,
      );
  @override
  Stream<String?> get outputErrorEmail => outputIsEmailValid.map(
        (isValid) => isValid ? null : AppStrings.emailInvalid,
      );
  @override
  Stream<String?> get outputErrorUserName => outputIsUserNameValid.map(
        (isValid) => isValid ? null : AppStrings.userNameInvalid,
      );
  @override
  Stream<String?> get outputErrorPassword => outputIsPasswordValid.map(
        (isValid) => isValid ? null : AppStrings.passwordInvalid,
      );

  @override
  Stream<bool> get outputIsEmailValid => _emailController.stream.map(
        (email) => isEmailValid(email),
      );
  @override
  Stream<bool> get outputIsMobileNumberValid =>
      _mobileNumberController.stream.map(
        (mobileNumber) => _isMobileNumberValid(mobileNumber),
      );
  @override
  Stream<bool> get outputIsUserNameValid => _userNameController.stream.map(
        (userName) => _isUserNameValid(userName),
      );
  @override
  Stream<bool> get outputIsPasswordValid => _passwordController.stream.map(
        (password) => _isPasswordValid(password),
      );
  @override
  Stream<File> get outputIsProfilePictureValid =>
      _profilePictureController.stream.map((profilePicture) => profilePicture);

  // set values
  @override
  setEmail(String email) {
    if (isEmailValid(email)) {
      registerObject = registerObject.copyWith(email: email);
    } else {
      registerObject = registerObject.copyWith(email: "");
    }
  }

  @override
  setCountryCode(String countryCode) {
    if (countryCode.isNotEmpty) {
      registerObject = registerObject.copyWith(countryMobileCode: countryCode);
    } else {
      registerObject = registerObject.copyWith(countryMobileCode: "");
    }
  }

  @override
  setMobileNumber(String mobileNumber) {
    if (_isMobileNumberValid(mobileNumber)) {
      registerObject = registerObject.copyWith(mobileNumber: mobileNumber);
    } else {
      registerObject = registerObject.copyWith(mobileNumber: "");
    }
  }

  @override
  setUserName(String username) {
    if (_isUserNameValid(username)) {
      registerObject = registerObject.copyWith(userName: username);
    } else {
      registerObject = registerObject.copyWith(userName: "");
    }
  }

  @override
  setPassword(String password) {
    if (_isPasswordValid(password)) {
      registerObject = registerObject.copyWith(password: password);
    } else {
      registerObject = registerObject.copyWith(password: "");
    }
  }

  @override
  setProfilePicture(File profilePicture) {
    if (profilePicture.path.isNotEmpty) {
      registerObject = registerObject.copyWith(
        profilePicture: profilePicture.path,
      );
    } else {
      registerObject = registerObject.copyWith(profilePicture: "");
    }
  }
}