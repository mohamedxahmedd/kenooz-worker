import 'package:flutter_easyloading/flutter_easyloading.dart';

void showLoading({
  EasyLoadingMaskType maskType = EasyLoadingMaskType.clear,
}) {
  EasyLoading.show(maskType: maskType);
}

void hideLoading() {
  EasyLoading.dismiss();
}

void showError(String message) {
  EasyLoading.dismiss();

  EasyLoading.showError(
    message,
    dismissOnTap: true,
  );
}

void showSuccess(String message) {
  EasyLoading.dismiss();

  EasyLoading.showSuccess(
    message,
    dismissOnTap: true,
  );
}

void showInfo(String message) {
  EasyLoading.dismiss();

  EasyLoading.showInfo(
    message,
    dismissOnTap: true,
  );
}
