import 'package:easy_localization/easy_localization.dart';
import 'package:virice/generated/locale_keys.g.dart';

class DiseaseDetail {
  final int diseaseName;
  DiseaseDetail(this.diseaseName);
  String getName() {
    switch (this.diseaseName) {
      case 0:
        return LocaleKeys.diseaseName_brownSpot.tr();
      case 1:
        return LocaleKeys.diseaseName_healthy.tr();
      case 2:
        return LocaleKeys.diseaseName_hispa.tr();
      case 3:
        return LocaleKeys.diseaseName_leafBlast.tr();
      default:
        return LocaleKeys.diseaseName_unknown.tr();
    }
  }

  String getReason() {
    switch (this.diseaseName) {
      case 0:
        return LocaleKeys.diseaseReason_brownSpot.tr();
      case 1:
        return LocaleKeys.diseaseReason_healthy.tr();
      case 2:
        return LocaleKeys.diseaseReason_hispa.tr();
      case 3:
        return LocaleKeys.diseaseReason_leafBlast.tr();
      default:
        return LocaleKeys.diseaseReason_unknown.tr();
    }
  }

  String getSolution() {
    switch (this.diseaseName) {
      case 0:
        return LocaleKeys.diseaseSolution_brownSpot.tr();
      case 1:
        return LocaleKeys.diseaseSolution_healthy.tr();
      case 2:
        return LocaleKeys.diseaseSolution_hispa.tr();
      case 3:
        return LocaleKeys.diseaseSolution_leafBlast.tr();
      default:
        return LocaleKeys.diseaseSolution_unknown.tr();
    }
  }
}
